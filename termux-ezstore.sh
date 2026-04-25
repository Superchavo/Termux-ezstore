#!/bin/bash

# --- SYSTEM SETUP ---
export XDG_DATA_DIRS=$PREFIX/share
export GTK_THEME=Adwaita
export ICON_THEME=Adwaita
TMP_LIST="$PREFIX/tmp/ezstore_list"
APP_ICON="software-store"

mkdir -p "$PREFIX/tmp"

# --- STRINGS ---
T_MAIN="Termux App Store 🚀"
T_LOG="Terminal Console"
B_INSTALL="Install"
B_REMOVE="Uninstall"
B_BACK="Back"

# --- CORE ENGINE ---
run_task() {
    $1 2>&1 | yad --text-info --title="$T_LOG" --window-icon="$APP_ICON" \
        --width=600 --height=400 --button="OK:0" --auto-scroll --center
}

manage_pkg() {
    # LIMPIEZA AGRESIVA: Solo permitimos caracteres válidos de nombres de paquetes
    local PKG_NAME=$(echo "$1" | sed 's/.*|//' | sed 's/system-search//g' | tr -d '|' | xargs)
    
    if [ -z "$PKG_NAME" ]; then return; fi
    
    if dpkg -s "$PKG_NAME" >/dev/null 2>&1; then
        yad --title="Manage" --window-icon="$APP_ICON" --width=400 --center \
            --text="\n📦 <b>App:</b> $PKG_NAME\n✅ <b>Status:</b> Installed\n" \
            --button="$B_REMOVE:0" --button="$B_BACK:1"
        [ $? -eq 0 ] && run_task "pkg uninstall $PKG_NAME -y"
    else
        yad --title="Install" --window-icon="$APP_ICON" --width=400 --center \
            --text="\n📦 <b>App:</b> $PKG_NAME\n⚠️ <b>Status:</b> Not installed\n\nDo you want to install it?" \
            --button="$B_INSTALL:0" --button="$B_BACK:1"
        [ $? -eq 0 ] && run_task "pkg install $PKG_NAME -y"
    fi
}

# --- SEARCH ENGINE (SNIPER MODE) ---
fetch_and_show() {
    local MODE="$1"
    local QUERY="$2"
    
    (
    echo "50" ; echo "# Filtering packages..."
    
    case "$MODE" in
        "INSTALLED") 
            pkg list-installed 2>/dev/null | cut -d/ -f1 > "$TMP_LIST" ;;
        "SEARCH") 
            # BUSQUEDA SNIPER: Solo paquetes que EMPIECEN con tu búsqueda
            # Usamos ^ para indicar el inicio de la línea
            pkg list-all 2>/dev/null | grep -i "^$QUERY" | cut -d/ -f1 > "$TMP_LIST" 
            # Si la búsqueda exacta falla, intentamos una búsqueda contenida pero limpia
            if [ ! -s "$TMP_LIST" ]; then
                pkg list-all 2>/dev/null | grep -i "$QUERY" | cut -d/ -f1 | grep "$QUERY" > "$TMP_LIST"
            fi
            ;;
        "GAMES") pkg list-all 2>/dev/null | grep "/stable" | cut -d/ -f1 > "$TMP_LIST" ;;
        "X11")   pkg list-all 2>/dev/null | grep "/x11" | cut -d/ -f1 > "$TMP_LIST" ;;
        "TUR")   pkg list-all 2>/dev/null | grep "/tur-packages" | cut -d/ -f1 > "$TMP_LIST" ;;
        "ROOT")  pkg list-all 2>/dev/null | grep "/root" | cut -d/ -f1 > "$TMP_LIST" ;;
    esac
    echo "100" ; echo "# Done"
    ) | yad --progress --title="Loading" --width=300 --center --auto-close --pulsate --nobutton

    if [ ! -s "$TMP_LIST" ]; then
        yad --error --text="No packages found." --center --width=300
        return
    fi

    SELECTED=$(cat "$TMP_LIST" | sort -u | yad --list --title="Results" --window-icon="$APP_ICON" \
        --column="Package Name" --width=500 --height=700 --center \
        --button="Select:0" --button="$B_BACK:1")
    
    CLEAN_VAL=$(echo "$SELECTED" | cut -d'|' -f1)
    [ ! -z "$CLEAN_VAL" ] && manage_pkg "$CLEAN_VAL"
}

# --- MAIN MENU ---
while true; do
    CHOICE=$(yad --title="$T_MAIN" --window-icon="$APP_ICON" \
        --list --column="Icon:IMG" --column="Category" --column="ID" \
        --print-column=3 --hide-column=3 --width=550 --height=800 --center \
        --text="\n<b>Termux Store</b>\n" \
        "system-search" "Search Packages" "DO_SEARCH" \
        "package-x-generic" "Installed Apps" "INSTALLED" \
        "applications-games" "Main Repository" "GAMES" \
        "video-display" "X11 Apps" "X11" \
        "folder-remote" "TUR Repository" "TUR" \
        "preferences-system-privacy" "Root Utilities" "ROOT" \
        "view-refresh" "Update Database" "UPDATE" \
        "application-exit" "Exit" "EXIT")

    # Limpieza total del ID para evitar el bug de "system-search"
    ID=$(echo "$CHOICE" | awk -F'|' '{print $1}' | xargs)
    
    case "$ID" in
        "DO_SEARCH") 
            IN=$(yad --entry --title="Search" --text="Type package name (e.g. k):" --window-icon="$APP_ICON")
            [ ! -z "$IN" ] && fetch_and_show "SEARCH" "$IN" ;;
        "INSTALLED") fetch_and_show "INSTALLED" ;;
        "GAMES") fetch_and_show "GAMES" ;;
        "X11")   fetch_and_show "X11" ;;
        "TUR")   fetch_and_show "TUR" ;;
        "ROOT")  fetch_and_show "ROOT" ;;
        "UPDATE") run_task "pkg update" ;;
        "EXIT"|"") exit 0 ;;
    esac
done
