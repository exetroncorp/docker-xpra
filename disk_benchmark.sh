#!/bin/bash
# Disk Performance Benchmark - IOPS & Throughput
# Teste les performances réelles de ton disque

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_DIR="${1:-/tmp}"
TEST_FILE="$TEST_DIR/disk_benchmark_test"
TEST_SIZE_GB=2

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       DISK PERFORMANCE BENCHMARK                       ║${NC}"
echo -e "${BLUE}║       Testing: $TEST_DIR"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier fio
if ! command -v fio &> /dev/null; then
    echo -e "${YELLOW}⚠️  fio n'est pas installé. Installation...${NC}"
    apt-get update && apt-get install -y fio
fi

# Fonction pour afficher les résultats
print_result() {
    local test_name=$1
    local value=$2
    local unit=$3
    local threshold=$4
    local comparison=$5
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}TEST: $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ "$comparison" = "gt" ]; then
        if (( $(echo "$value > $threshold" | bc -l) )); then
            echo -e "Résultat: ${GREEN}$value $unit ✅${NC}"
            echo -e "Status:   ${GREEN}EXCELLENT${NC} (> $threshold $unit)"
        else
            echo -e "Résultat: ${RED}$value $unit ❌${NC}"
            echo -e "Status:   ${RED}INSUFFISANT${NC} (seuil: $threshold $unit)"
        fi
    else
        if (( $(echo "$value < $threshold" | bc -l) )); then
            echo -e "Résultat: ${GREEN}$value $unit ✅${NC}"
            echo -e "Status:   ${GREEN}EXCELLENT${NC} (< $threshold $unit)"
        else
            echo -e "Résultat: ${RED}$value $unit ❌${NC}"
            echo -e "Status:   ${RED}PROBLÈME${NC} (seuil: $threshold $unit)"
        fi
    fi
}

# Informations sur le disque
echo -e "\n${BLUE}📊 Informations du système de fichiers${NC}"
df -h "$TEST_DIR" | tail -1
echo ""
mount | grep "$(df "$TEST_DIR" | tail -1 | awk '{print $1}')"
echo ""

# ============================================
# TEST 1: IOPS Lecture Aléatoire (4K)
# ============================================
echo -e "\n${YELLOW}🔍 Test 1/6: IOPS Lecture Aléatoire (4K blocks)${NC}"
echo "   Ce test simule les opérations de lecture d'IntelliJ..."

fio --name=random-read-iops \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=randread \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=4 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_randread.json &> /dev/null

READ_IOPS=$(jq -r '.jobs[0].read.iops' /tmp/fio_randread.json | cut -d. -f1)
print_result "IOPS Lecture Aléatoire (4K)" "$READ_IOPS" "IOPS" "5000" "gt"

echo -e "\n💡 Référence:"
echo "   - NVMe SSD:     100,000+ IOPS"
echo "   - SATA SSD:     10,000-75,000 IOPS"
echo "   - HDD local:    100-200 IOPS"
echo "   - NFS/Réseau:   100-1,000 IOPS (⚠️  problème pour IDE)"

# ============================================
# TEST 2: IOPS Écriture Aléatoire (4K)
# ============================================
echo -e "\n${YELLOW}🔍 Test 2/6: IOPS Écriture Aléatoire (4K blocks)${NC}"
echo "   Ce test simule l'écriture de fichiers de build..."

fio --name=random-write-iops \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=randwrite \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=4 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_randwrite.json &> /dev/null

WRITE_IOPS=$(jq -r '.jobs[0].write.iops' /tmp/fio_randwrite.json | cut -d. -f1)
print_result "IOPS Écriture Aléatoire (4K)" "$WRITE_IOPS" "IOPS" "5000" "gt"

# ============================================
# TEST 3: Throughput Lecture Séquentielle
# ============================================
echo -e "\n${YELLOW}🔍 Test 3/6: Throughput Lecture Séquentielle (1M blocks)${NC}"
echo "   Ce test simule la lecture de gros fichiers..."

fio --name=seq-read-throughput \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=read \
    --bs=1M \
    --direct=1 \
    --size=2G \
    --numjobs=1 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_seqread.json &> /dev/null

READ_BW=$(jq -r '.jobs[0].read.bw' /tmp/fio_seqread.json | cut -d. -f1)
READ_BW_MB=$((READ_BW / 1024))
print_result "Throughput Lecture Séquentielle" "$READ_BW_MB" "MB/s" "100" "gt"

echo -e "\n💡 Référence:"
echo "   - NVMe SSD:     2,000-7,000 MB/s"
echo "   - SATA SSD:     500-550 MB/s"
echo "   - HDD local:    100-200 MB/s"
echo "   - NFS/Réseau:   10-100 MB/s (⚠️  lent)"

# ============================================
# TEST 4: Throughput Écriture Séquentielle
# ============================================
echo -e "\n${YELLOW}🔍 Test 4/6: Throughput Écriture Séquentielle (1M blocks)${NC}"
echo "   Ce test simule la compilation et génération de fichiers..."

fio --name=seq-write-throughput \
    --ioengine=libaio \
    --iodepth=32 \
    --rw=write \
    --bs=1M \
    --direct=1 \
    --size=2G \
    --numjobs=1 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_seqwrite.json &> /dev/null

WRITE_BW=$(jq -r '.jobs[0].write.bw' /tmp/fio_seqwrite.json | cut -d. -f1)
WRITE_BW_MB=$((WRITE_BW / 1024))
print_result "Throughput Écriture Séquentielle" "$WRITE_BW_MB" "MB/s" "100" "gt"

# ============================================
# TEST 5: Latence (très important!)
# ============================================
echo -e "\n${YELLOW}🔍 Test 5/6: Latence d'accès${NC}"
echo "   Ce test mesure le temps de réponse du disque..."

fio --name=latency-test \
    --ioengine=libaio \
    --iodepth=1 \
    --rw=randread \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=1 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_latency.json &> /dev/null

LATENCY_US=$(jq -r '.jobs[0].read.lat_ns.mean' /tmp/fio_latency.json)
LATENCY_MS=$(echo "scale=2; $LATENCY_US / 1000000" | bc)
print_result "Latence moyenne" "$LATENCY_MS" "ms" "10" "lt"

echo -e "\n💡 Référence:"
echo "   - NVMe SSD:     < 0.1 ms"
echo "   - SATA SSD:     < 1 ms"
echo "   - HDD local:    5-10 ms"
echo "   - NFS/Réseau:   10-100 ms (⚠️  très lent pour IDE)"

# ============================================
# TEST 6: Test IntelliJ-like (mixed workload)
# ============================================
echo -e "\n${YELLOW}🔍 Test 6/6: Simulation workload IntelliJ${NC}"
echo "   Mix de lecture/écriture comme IntelliJ en action..."

fio --name=intellij-simulation \
    --ioengine=libaio \
    --iodepth=16 \
    --rw=randrw \
    --rwmixread=70 \
    --bs=4k \
    --direct=1 \
    --size=1G \
    --numjobs=4 \
    --runtime=30 \
    --group_reporting \
    --filename="$TEST_FILE" \
    --output-format=json \
    --output=/tmp/fio_mixed.json &> /dev/null

MIXED_READ_IOPS=$(jq -r '.jobs[0].read.iops' /tmp/fio_mixed.json | cut -d. -f1)
MIXED_WRITE_IOPS=$(jq -r '.jobs[0].write.iops' /tmp/fio_mixed.json | cut -d. -f1)
TOTAL_IOPS=$((MIXED_READ_IOPS + MIXED_WRITE_IOPS))

print_result "IntelliJ Simulation (mixed)" "$TOTAL_IOPS" "IOPS" "3000" "gt"

# ============================================
# RÉSUMÉ FINAL
# ============================================
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  RÉSUMÉ FINAL                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

echo -e "\n📊 Performances mesurées:"
echo -e "   • IOPS Lecture:           ${GREEN}$READ_IOPS${NC} IOPS"
echo -e "   • IOPS Écriture:          ${GREEN}$WRITE_IOPS${NC} IOPS"
echo -e "   • Throughput Lecture:     ${GREEN}$READ_BW_MB${NC} MB/s"
echo -e "   • Throughput Écriture:    ${GREEN}$WRITE_BW_MB${NC} MB/s"
echo -e "   • Latence:                ${GREEN}$LATENCY_MS${NC} ms"
echo -e "   • IOPS Mixed (IntelliJ):  ${GREEN}$TOTAL_IOPS${NC} IOPS"

# Diagnostic
echo -e "\n🎯 DIAGNOSTIC POUR INTELLIJ:"

if [ "$READ_IOPS" -lt 3000 ] || [ "$LATENCY_MS" -gt "10" ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}⚠️  PERFORMANCES INSUFFISANTES POUR IDE${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Ton disque est probablement un volume monté réseau/NFS.${NC}"
    echo -e "${YELLOW}IntelliJ va ramer comme un escargot! 🐌${NC}"
    echo ""
    echo -e "Solutions:"
    echo "  1. Utilise un volume local/SSD pour le workspace"
    echo "  2. Monte /tmp en tmpfs pour les caches IntelliJ"
    echo "  3. Configure IntelliJ pour utiliser /tmp pour les caches"
    echo "  4. Exclus les gros dossiers (node_modules, .git, build/)"
    echo ""
    echo "Commande pour ton pod Kubernetes:"
    echo "  volumeMounts:"
    echo "    - name: workspace"
    echo "      mountPath: /home/coder/workspace"
    echo "    - name: cache"
    echo "      mountPath: /home/coder/.cache"
    echo "  volumes:"
    echo "    - name: cache"
    echo "      emptyDir: {}"  # Volume local, pas NFS!
elif [ "$READ_IOPS" -lt 10000 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  PERFORMANCES MOYENNES${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "IntelliJ fonctionnera mais tu peux améliorer:"
    echo "  • Utilise un SSD au lieu d'un HDD"
    echo "  • Optimise les paramètres IntelliJ"
    echo "  • Exclus les dossiers lourds de l'indexation"
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ EXCELLENTES PERFORMANCES!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Ton disque est parfait pour IntelliJ! 🚀"
fi

# Cleanup
rm -f "$TEST_FILE" /tmp/fio_*.json

echo -e "\n${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${GREEN}✅ Benchmark terminé!${NC}"
echo ""
