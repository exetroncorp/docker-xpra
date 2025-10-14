#!/bin/bash

################################################################################
# IntelliJ IDEA 2025.2.3 Setup for Rootless Debian 12 Container
# Purpose: Configure plugins, proxy, GitLab, and memory constraints
# Requirements: IntelliJ IDEA installed, bash 4+
################################################################################

set -euo pipefail

################################################################################
# CONFIGURATION SECTION - Modify these values
################################################################################

# IntelliJ Paths
INTELLIJ_HOME="${INTELLIJ_HOME:-/home/coder/.local/share/JetBrains/IntelliJIdea2025.2}"
INTELLIJ_CONFIG_PATH="${INTELLIJ_CONFIG_PATH:-/home/coder/.config/JetBrains/IntelliJIdea2025.2}"
INTELLIJ_PLUGINS_PATH="${INTELLIJ_PLUGINS_PATH:-${INTELLIJ_CONFIG_PATH}/plugins}"

# Proxy Configuration
PROXY_ENABLED=true
PROXY_HOST="127.0.0.1"
PROXY_PORT="7777"
PROXY_TYPE="HTTP"  # HTTP or SOCKS

# GitLab Configuration
GITLAB_ENABLED=true
GITLAB_URL="http://mygitlab.com"
GITLAB_TOKEN_STORAGE="git-credential-store"  # Options: git-credential-store, keepass, env
GITLAB_TOKEN_ENV_VAR="GITLAB_ACCESS_TOKEN"

# Memory and VM Options
VM_XMX="6g"          # Maximum heap size (leave 2GB for system)
VM_XMS="2g"          # Initial heap size
VM_XX_OPTS="-XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:+ParallelRefProcEnabled"

# Writable directories (for this environment)
WRITABLE_DIRS=("/home/coder" "/tmp")

# Logging
LOG_FILE="/tmp/intellij_setup.log"
VERBOSE=true

################################################################################
# UTILITY FUNCTIONS
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_warn() {
    log "WARN" "$@"
}

is_writable() {
    local path="$1"
    if [[ -w "$path" ]]; then
        return 0
    else
        return 1
    fi
}

verify_writable_dirs() {
    log_info "Verifying writable directories..."
    local all_writable=true
    
    for dir in "${WRITABLE_DIRS[@]}"; do
        if is_writable "$dir"; then
            log_info "✓ $dir is writable"
        else
            log_error "✗ $dir is NOT writable"
            all_writable=false
        fi
    done
    
    if [[ "$all_writable" == false ]]; then
        log_error "Some required directories are not writable"
        return 1
    fi
}

create_directories() {
    log_info "Creating necessary directories..."
    mkdir -p "${INTELLIJ_CONFIG_PATH}"
    mkdir -p "${INTELLIJ_PLUGINS_PATH}"
    mkdir -p "$(dirname "${LOG_FILE}")"
    log_info "Directories created successfully"
}

################################################################################
# PLUGIN INSTALLATION
################################################################################

install_plugin() {
    local plugin_url="$1"
    local plugin_version="$2"
    local plugin_id="$3"
    
    log_info "Installing plugin: ID=$plugin_id, Version=$plugin_version"
    log_info "Plugin URL: $plugin_url"
    
    if [[ -z "$plugin_url" ]] || [[ -z "$plugin_version" ]] || [[ -z "$plugin_id" ]]; then
        log_error "Missing required parameters for plugin installation"
        log_error "Usage: install_plugin <url> <version> <id>"
        return 1
    fi
    
    # Create plugin directory
    local plugin_dir="${INTELLIJ_PLUGINS_PATH}/${plugin_id}"
    mkdir -p "${plugin_dir}"
    
    # Download plugin JAR
    log_info "Downloading plugin from: $plugin_url"
    local temp_jar="/tmp/${plugin_id}-${plugin_version}.jar"
    
    if ! curl -fsSL -o "${temp_jar}" "${plugin_url}"; then
        log_error "Failed to download plugin from $plugin_url"
        return 1
    fi
    
    # Verify download
    if [[ ! -f "${temp_jar}" ]]; then
        log_error "Downloaded file not found: $temp_jar"
        return 1
    fi
    
    log_info "Download successful: $(ls -lh "${temp_jar}" | awk '{print $5, $9}')"
    
    # Extract plugin (IntelliJ plugins are typically ZIP files)
    log_info "Extracting plugin to: $plugin_dir"
    if unzip -q -o "${temp_jar}" -d "${plugin_dir}" 2>/dev/null || cp "${temp_jar}" "${plugin_dir}/"; then
        log_info "✓ Plugin installed successfully"
    else
        log_error "Failed to extract/copy plugin"
        return 1
    fi
    
    # Cleanup
    rm -f "${temp_jar}"
    log_info "Plugin setup completed for: $plugin_id"
}

install_plugins_batch() {
    local -n plugins_array=$1
    local failed=0
    
    log_info "Installing ${#plugins_array[@]} plugin(s)..."
    
    for plugin in "${plugins_array[@]}"; do
        IFS='|' read -r url version id <<< "$plugin"
        if ! install_plugin "$url" "$version" "$id"; then
            ((failed++))
            log_warn "Failed to install plugin: $id"
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        log_info "✓ All plugins installed successfully"
        return 0
    else
        log_warn "⚠ $failed plugin(s) failed to install"
        return 1
    fi
}

################################################################################
# PROXY CONFIGURATION
################################################################################

configure_proxy() {
    log_info "Configuring proxy settings..."
    
    if [[ "$PROXY_ENABLED" != true ]]; then
        log_info "Proxy configuration is disabled"
        return 0
    fi
    
    local options_file="${INTELLIJ_CONFIG_PATH}/idea.properties"
    
    # Create or backup existing properties
    if [[ -f "$options_file" ]]; then
        log_info "Backing up existing idea.properties"
        cp "${options_file}" "${options_file}.backup.$(date +%s)"
    fi
    
    log_info "Setting proxy to ${PROXY_TYPE}://${PROXY_HOST}:${PROXY_PORT}"
    
    cat >> "${options_file}" << EOF

# Proxy Configuration - Generated $(date)
idea.http.proxy=${PROXY_HOST}
idea.http.proxy.port=${PROXY_PORT}
idea.https.proxy=${PROXY_HOST}
idea.https.proxy.port=${PROXY_PORT}
idea.socks.proxy=${PROXY_HOST}
idea.socks.proxy.port=${PROXY_PORT}
idea.proxy.type=${PROXY_TYPE}

EOF
    
    log_info "✓ Proxy configuration applied"
}

################################################################################
# GITLAB CONFIGURATION
################################################################################

setup_git_credentials_store() {
    log_info "Setting up Git credential storage for GitLab..."
    
    # Configure git to use credential-store
    git config --global credential.helper store
    
    # Create credentials file in /home/coder (writable)
    local cred_file="/home/coder/.git-credentials"
    
    if [[ -z "${!GITLAB_TOKEN_ENV_VAR:-}" ]]; then
        log_warn "GitLab token not found in environment variable: $GITLAB_TOKEN_ENV_VAR"
        log_info "Please set: export $GITLAB_TOKEN_ENV_VAR='your_token_here'"
        log_info "Then run: echo \"${GITLAB_URL} login token\" >> ${cred_file}"
        return 0
    fi
    
    # Create credentials entry
    local token="${!GITLAB_TOKEN_ENV_VAR}"
    echo "https://oauth2:${token}@${GITLAB_URL#*://}" >> "${cred_file}"
    chmod 600 "${cred_file}"
    
    log_info "✓ Git credentials stored securely"
}

configure_gitlab() {
    log_info "Configuring GitLab integration..."
    
    if [[ "$GITLAB_ENABLED" != true ]]; then
        log_info "GitLab configuration is disabled"
        return 0
    fi
    
    log_info "GitLab Server URL: $GITLAB_URL"
    
    # Configure based on token storage method
    case "$GITLAB_TOKEN_STORAGE" in
        git-credential-store)
            log_info "Using Git credential store for authentication"
            setup_git_credentials_store
            ;;
        keepass)
            log_warn "KeePass storage requires manual IDE configuration"
            log_info "Settings > Version Control > GitLab > Host: $GITLAB_URL"
            log_info "Use IDE's KeePass plugin to store credentials securely"
            ;;
        env)
            log_warn "Using environment variable (less secure for production)"
            if [[ -z "${!GITLAB_TOKEN_ENV_VAR:-}" ]]; then
                log_warn "Environment variable $GITLAB_TOKEN_ENV_VAR is not set"
            fi
            ;;
    esac
    
    # Create gitconfig snippet
    local gitconfig_snippet="/tmp/gitlab_gitconfig.snippet"
    cat > "${gitconfig_snippet}" << EOF
# GitLab Configuration
[remote "origin"]
    url = ${GITLAB_URL}

EOF
    
    log_info "✓ GitLab configuration completed"
    log_info "GitLab config snippet saved to: $gitconfig_snippet"
}

################################################################################
# JVM MEMORY AND VM OPTIONS
################################################################################

configure_jvm_options() {
    log_info "Configuring JVM options for 4 CPU, 8GB RAM environment..."
    
    local vmoptions_file="${INTELLIJ_CONFIG_PATH}/idea.vmoptions"
    
    # Backup existing if present
    if [[ -f "$vmoptions_file" ]]; then
        log_info "Backing up existing idea.vmoptions"
        cp "${vmoptions_file}" "${vmoptions_file}.backup.$(date +%s)"
    fi
    
    log_info "Memory settings: Xms=${VM_XMS}, Xmx=${VM_XMX}"
    
    cat > "${vmoptions_file}" << EOF
# JVM Options for Rootless Container (4 CPU, 8GB RAM)
# Generated: $(date)

# Heap Memory
-Xms${VM_XMS}
-Xmx${VM_XMX}

# Garbage Collection (G1GC optimized for containers)
${VM_XX_OPTS}
-XX:+UseStringDeduplication
-XX:+UnlockExperimentalVMOptions
-XX:G1NewCollectionHeuristicWeight=35

# Logging
-Xloggc:/tmp/intellij_gc.log
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-XX:+PrintGCTimeStamps

# Container-aware settings
-XX:ActiveProcessorCount=4
-XX:+UseContainerSupport
-XX:InitialCodeCacheSize=512m
-XX:ReservedCodeCacheSize=512m

# Disable features not needed in container
-Dcom.sun.tools.jdi.ProcessAttachingConnector.resolveExecutablesInPath=false

# File encoding
-Dfile.encoding=UTF-8
-Dfile.encoding.pkg=UTF-8

EOF
    
    log_info "✓ JVM options configured"
}

################################################################################
# INTELLIJ-SPECIFIC SETTINGS
################################################################################

configure_ide_settings() {
    log_info "Configuring IDE settings for resource constraints..."
    
    local settings_dir="${INTELLIJ_CONFIG_PATH}/options"
    mkdir -p "${settings_dir}"
    
    # UI performance optimizations
    cat > "${settings_dir}/ui.lnf.xml" << 'EOF'
<application>
  <component name="UISettings">
    <option name="ANIMATED_SCROLLING" value="false" />
    <option name="SHOW_MEMORY_INDICATOR" value="true" />
    <option name="SHOW_MAIN_TOOLBAR" value="true" />
    <option name="PRESENTATION_MODE" value="false" />
  </component>
</application>
EOF
    
    # Editor performance
    cat > "${settings_dir}/editor.xml" << 'EOF'
<application>
  <component name="EditorSettings">
    <option name="SHOW_BREADCRUMBS" value="false" />
    <option name="HIGHLIGHT_BRACES" value="true" />
  </component>
  <component name="CodeInsightSettings">
    <option name="REFORMAT_ON_PASTE" value="INDENT" />
    <option name="INDENT_TO_CURSOR" value="false" />
  </component>
</application>
EOF
    
    log_info "✓ IDE settings optimized"
}

################################################################################
# SYSTEM REQUIREMENTS VALIDATION
################################################################################

validate_environment() {
    log_info "Validating environment..."
    
    # Check required tools
    local required_tools=("curl" "unzip" "git")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log_info "✓ $tool found"
        else
            log_error "✗ Required tool not found: $tool"
            return 1
        fi
    done
    
    # Check write permissions
    verify_writable_dirs
    
    # Check IntelliJ installation
    if [[ -d "$INTELLIJ_HOME" ]]; then
        log_info "✓ IntelliJ found at: $INTELLIJ_HOME"
    else
        log_warn "⚠ IntelliJ home not found at: $INTELLIJ_HOME"
        log_info "You may need to update INTELLIJ_HOME variable"
    fi
    
    log_info "✓ Environment validation completed"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    log_info "=========================================="
    log_info "IntelliJ IDEA Setup - Starting"
    log_info "=========================================="
    
    # Validation
    validate_environment || return 1
    
    # Setup
    create_directories
    configure_jvm_options
    configure_proxy
    configure_gitlab
    configure_ide_settings
    
    log_info "=========================================="
    log_info "✓ Setup completed successfully"
    log_info "=========================================="
    log_info "Log file: $LOG_FILE"
    log_info "Config path: $INTELLIJ_CONFIG_PATH"
    log_info ""
    log_info "Next steps:"
    log_info "1. Review configuration in: $INTELLIJ_CONFIG_PATH"
    log_info "2. Restart IntelliJ IDEA"
    log_info "3. Verify settings: Help > Show Log in Explorer"
}

################################################################################
# PLUGIN INSTALLATION EXAMPLES
################################################################################

install_plugins_example() {
    # Example: Install multiple plugins
    # Format: "URL|VERSION|PLUGIN_ID"
    
    local plugins=(
        "https://plugins.jetbrains.com/plugin/download?pluginId=org.jetbrains.plugins.github&version=1.0.0|1.0.0|org.jetbrains.plugins.github"
        "https://plugins.jetbrains.com/plugin/download?pluginId=Git4Idea&version=2025.2|2025.2|Git4Idea"
    )
    
    install_plugins_batch plugins
}

# Run main setup
main "$@"
