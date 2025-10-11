#!/bin/sh

# Fichier de test qui sera créé dans le répertoire de l'utilisateur
# Il sera supprimé automatiquement à la fin du script.
TEST_FILE="/home/coder/fio_test_file"

# Taille du fichier de test. Assez grand pour être pertinent,
# mais pas trop pour ne pas prendre des heures.
FILE_SIZE="2G"

# Durée de chaque test en secondes
RUNTIME=60

# Nettoyage au cas où un précédent test aurait échoué
rm -f ${TEST_FILE}

echo "################################################################"
echo "## Lancement des tests de performance I/O avec FIO"
echo "## Répertoire de test : /home/coder"
echo "## Taille du fichier de test : ${FILE_SIZE}"
echo "################################################################"
echo ""

# --- Test 1: IOPS en écriture aléatoire (Random Write) ---
# Simule une charge de travail type base de données avec des petits blocs (4k)
echo "--> Test en cours : IOPS en écriture aléatoire (4k blocks)..."
fio --name=randwrite_iops --rw=randwrite --bs=4k --size=${FILE_SIZE} \
    --directory=/home/coder --filename=${TEST_FILE} \
    --runtime=${RUNTIME} --time_based --direct=1 --group_reporting \
    --ioengine=libaio --iodepth=64
echo ""
echo "--> FIN du test d'IOPS en écriture."
echo ""

# --- Test 2: IOPS en lecture aléatoire (Random Read) ---
# Simule la lecture aléatoire de petits fichiers
echo "--> Test en cours : IOPS en lecture aléatoire (4k blocks)..."
fio --name=randread_iops --rw=randread --bs=4k --size=${FILE_SIZE} \
    --directory=/home/coder --filename=${TEST_FILE} \
    --runtime=${RUNTIME} --time_based --direct=1 --group_reporting \
    --ioengine=libaio --iodepth=64
echo ""
echo "--> FIN du test d'IOPS en lecture."
echo ""

# --- Test 3: Débit en écriture séquentielle (Sequential Write Throughput) ---
# Simule l'écriture de gros fichiers avec des blocs plus larges (1M)
echo "--> Test en cours : Débit en écriture séquentielle (1M blocks)..."
fio --name=seqwrite_throughput --rw=write --bs=1M --size=${FILE_SIZE} \
    --directory=/home/coder --filename=${TEST_FILE} \
    --runtime=${RUNTIME} --time_based --direct=1 --group_reporting \
    --ioengine=libaio --iodepth=32
echo ""
echo "--> FIN du test de débit en écriture."
echo ""

# --- Test 4: Débit en lecture séquentielle (Sequential Read Throughput) ---
# Simule la lecture de gros fichiers
echo "--> Test en cours : Débit en lecture séquentielle (1M blocks)..."
fio --name=seqread_throughput --rw=read --bs=1M --size=${FILE_SIZE} \
    --directory=/home/coder --filename=${TEST_FILE} \
    --runtime=${RUNTIME} --time_based --direct=1 --group_reporting \
    --ioengine=libaio --iodepth=32
echo ""
echo "--> FIN du test de débit en lecture."
echo ""

# Nettoyage final
rm -f ${TEST_FILE}

echo "################################################################"
echo "## Tous les tests sont terminés."
echo "################################################################"