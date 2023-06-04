#!/usr/bin/env bash
# Packages setup for Sublime Text 4 on MacOSX

APPLICATION="Sublime Text";
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="${HOME}/Library/Application Support/Sublime Text"
PACKAGED_DIR="${ROOT_DIR}/Installed Packages"
LOCAL_DIR="${ROOT_DIR}/Local"
PACKAGES_DIR="${ROOT_DIR}/Packages"
USER_DIR="${PACKAGES_DIR}/User"
ASSETS_DIR="${USER_DIR}/formatter.assets"
CFG_REPO="https://github.com/mi-sublime/dot"
CFG_DIR="${CFG_REPO##*/}-master"

# Pretty print
print () {
    if [ "$2" == "error" ] ; then
        COLOR="7;91m" # light red
    elif [ "$2" == "success" ] ; then
        COLOR="7;92m" # light green
    elif [ "$2" == "warning" ] ; then
        COLOR="7;33m" # yellow
    elif [ "$2" == "info" ] ; then
        COLOR="7;94m" # light blue
    else
        COLOR="0m" # colorless
    fi

    STARTCOLOR="\\e[$COLOR"
    ENDCOLOR="\\e[0m"

    printf "$STARTCOLOR%b$ENDCOLOR" "$1\\n"
}

# Check system
OS=$(uname -s)
if [ "${OS}" != "Darwin" ]; then
    print "[Error] ${OS} is not supported.\\nExit." "error" >&2
    exit 1
fi

# Create default folders
if open -Ra "${APPLICATION}"; then
    print "Creating ${APPLICATION} default folders" "success"
    open -a "${APPLICATION}"
    pkill -9 "${APPLICATION}"
else
    print "[Error] ${APPLICATION} does not exist.\\nExit." "error" >&2
    exit 1
fi

# Check PHP requirements
function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
cur="$(php -v | grep PHP -m 1 | awk '{print $2}')"
min=5.6.0 # Formatter (PHP-CS-Fixer)
if ! version_gt "$cur" "$min"; then
    print  "[Error] Current PHP ($cur) does not meet the minimum version requirement of PHP $min\\nExit." "error" >&2
    exit 1
fi

# Update pip3
print "Updating pip3" "info"
sudo -H pip3 install --upgrade pip

# Update all npm global packages
print "Updating npm global packages" "info"
sudo npm update -g

# Accept Xcode license
if [ "$(command -v xcodebuild)" ]; then
    sudo xcodebuild -license accept
fi

# Install plugins
mkdir -p "${ASSETS_DIR}/bin"

print "Installing php-cs-fixer" "info" # Formatter
# curl -Lk "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.17.0/php-cs-fixer.phar" --create-dirs -o "${ASSETS_DIR}/bin/php-cs-fixer.phar"
mv ./bin/php-cs-fixer.phar "${ASSETS_DIR}/bin/php-cs-fixer.phar"
sudo chmod a+x "${ASSETS_DIR}/bin/php-cs-fixer.phar"

print "Installing clang-format" "info" # Formatter
# curl -Lk "https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz" -o "clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz"
# tar -xzvf clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
# mv ./clang+llvm-15.0.7-x86_64-apple-darwin21.0/bin/clang-format "${ASSETS_DIR}/bin/clang-format"
# rm -rf clang+llvm-15.0.7-x86_64-apple-darwin21.0 && rm clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
mv ./bin/clang-format "${ASSETS_DIR}/bin/clang-format"
sudo chmod a+x "${ASSETS_DIR}/bin/clang-format"

print "Installing uncrustify" "info" # Formatter
# curl -Lk "https://github.com/uncrustify/uncrustify/archive/refs/heads/master.zip" -o "uncrustify-master.zip"
# tar -xzvf uncrustify-master.zip
# cd uncrustify-master
# mkdir build
# cd build
# /Applications/CMake.app/Contents/bin/cmake -DCMAKE_BUILD_TYPE=Release ..
# make
# mv ./uncrustify "${ASSETS_DIR}/bin/uncrustify"
# cd ..
# cd ..
# rm -rf uncrustify-master && rm uncrustify-master.zip
mv ./bin/uncrustify "${ASSETS_DIR}/bin/uncrustify"
sudo chmod a+x "${ASSETS_DIR}/bin/uncrustify"

print "Installing perltidy" "info" # Formatter
curl -Lk "https://github.com/perltidy/perltidy/archive/master.zip" -o "perltidy-master.zip"
tar -xzf "perltidy-master.zip"
cd "perltidy-master" || exit 1
perl pm2pl
mv "perltidy-20181120.01.pl" "${ASSETS_DIR}/bin/perltidy"
cd "${SCRIPT_DIR}" || exit 1
rm -rf "perltidy-master"
rm "perltidy-master.zip"
sudo chmod a+x "${ASSETS_DIR}/bin/perltidy"

print "Installing shellcheck" "info" # SublimeLinter-shellcheck
# curl -Lk "https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.darwin.x86_64.tar.xz" -o "shellcheck-v0.9.0.darwin.x86_64.tar.xz"
# tar -xzvf shellcheck-v0.9.0.darwin.x86_64.tar.xz
# mv ./shellcheck-v0.9.0/shellcheck "${ASSETS_DIR}/bin/shellcheck"
# rm -rf shellcheck-v0.9.0 && rm shellcheck-v0.9.0.darwin.x86_64.tar.xz
mv ./bin/shellcheck "${ASSETS_DIR}/bin/shellcheck"
sudo chmod a+x "${ASSETS_DIR}/bin/shellcheck"

print "Installing html-tidy" "info" # SublimeLinter-html-tidy + Formatter
# curl -Lk "https://github.com/htacg/tidy-html5/releases/download/5.8.0/tidy-5.8.0-macos-x86_64+arm64.pkg" -o "tidy-5.8.0-macos-x86_64+arm64.pkg"
# mkdir tmp
# mv tidy-5.8.0-macos-x86_64+arm64.pkg tmp
# cd tmp
# xar -xf tidy-5.8.0-macos-x86_64+arm64.pkg
# cd HTML_Tidy.pkg
# tar -xzvf Payload
# mv ./usr/local/bin/tidy "${ASSETS_DIR}/bin/tidy"
# cd ..
# cd ..
# rm -rf tmp
mv ./bin/tidy "${ASSETS_DIR}/bin/tidy"
sudo chmod a+x "${ASSETS_DIR}/bin/tidy"

# Logout sudo
print "Logout sudo" "success"
sudo -k

# Install plugins
declare -a bin=(
    "node"
    "python3"
    "ruby"
)

declare -a python=(
    "CodeIntel" # SublimeCodeIntel
    "pylint" # SublimeLinter-pylint
    "beautysh" # Formatter
    "black" # Formatter
    "yapf" # Formatter
)

declare -a ruby=(
    "rubocop" # Formatter
)

declare -a javascript=(
    "eslint" # SublimeLinter-eslint + Formatter
    "prettier" # SublimeLinter-eslint + SublimeLinter-stylelint + Formatter
    "stylelint" # SublimeLinter-stylelint + Formatter
    "csscomb" # Formatter
    "js-beautify" # Formatter
    "cleancss" # Formatter (clean-css-cli)
    "html-minifier" # Formatter
    "terser" # Formatter
)

for i in "${bin[@]}"; do
    if ! [ -x "$(command -v "${i}")" ]; then
        print "[Error] ${i} does not exist.\\nExit." "error" >&2
        exit 1
    fi
done

for i in "${python[@]}"; do
    print "Installing ${i}" "info"
    pip3 install --upgrade --pre --no-warn-script-location --prefix="${ASSETS_DIR}/python" "${i}"
done

for i in "${ruby[@]}"; do
    print "Installing ${i}" "info"
    gem install --install-dir "${ASSETS_DIR}/ruby" "${i}"
done

for i in "${javascript[@]}"; do
    print "Installing ${i}" "info"
    case "${i}" in
        "eslint")
            npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}" eslint-config-standard eslint-plugin-standard eslint-plugin-promise eslint-plugin-import eslint-plugin-node
            ;;
        "prettier")
            npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}" eslint-config-prettier eslint-plugin-prettier stylelint-config-prettier stylelint-prettier
            ;;
        "stylelint")
            npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}" postcss stylelint-config-recommended stylelint-config-standard stylelint-group-selectors stylelint-no-indistinguishable-colors stylelint-a11y
            ;;
        "cleancss")
            npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "clean-css-cli"
            ;;
        *)
            npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}"
            ;;
    esac
done

# Clone config branch
if [ -x "$(command -v git)" ]; then
    print "Cloning config master branch" "info"
    git clone "${CFG_REPO}.git" --branch "master" --single-branch "${CFG_DIR}"
else
    print "[Error] git does not exist.\\nExit." "error" >&2
    exit 1
fi

# Install assets
print "Installing config files" "info"
cp -R "${CFG_DIR}/Packages/User" "${PACKAGES_DIR}"

# Show hidden files for 'mv'
shopt -s dotglob

# Install lic files
for i in "${CFG_DIR}/Local/"*; do
    print "Installing ${i##*/}" "info"
    mv "${i}" "${LOCAL_DIR}"
done

# Install .sublime-package files
print "Installing Package Control.sublime-package" "info"
curl -Lk "https://packagecontrol.io/Package%20Control.sublime-package" --create-dirs -o "${PACKAGED_DIR}/Package Control.sublime-package"
print "Installing Sublimerge 3.sublime-package" "info"
curl -Lk "https://www.sublimerge.com/packages/ST3/latest/Sublimerge%203.sublime-package" --create-dirs -o "${PACKAGED_DIR}/Sublimerge 3.sublime-package"

# Remove config dir
print "Deleting ${CFG_DIR}" "info"
rm -rf "${CFG_DIR}"

print "${APPLICATION} needs a restart to finish installation.\\nDone." "success"
exit 1
