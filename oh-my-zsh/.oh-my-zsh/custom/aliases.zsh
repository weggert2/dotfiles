alias alpha_queue="sudo sysctl -w fs.mqueue.msg_max=256"
alias fprime_mmap="sudo sysctl vm.mmap_rnd_bits=28"
alias ac="cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias ab="ac && cmake --build build --parallel $(nproc)"
alias at="ab && ctest --test-dir build"
alias runtest='function _runtest() { make "$1" && (./"$1" || gdb ./"$1") ; }; _runtest'
alias hash_alpha_bins="cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --parallel 10 && find build/bin -type f -name '*.bin' | xargs -I {} md5sum {}"
alias etest="setarch `uname -m` -R bash -c \"fprime-util check -j16 --pass-through --rerun-failed --output-on-failure\""
alias sourcez="exec zsh"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias v.="nvim ."
alias rm="rm --verbose"
alias edz="nvim ~/.zshrc"
# alias gdb="gdb -tui --args"

teeclip() {
  if [ "$XDG_SESSION_TYPE" = "wayland" ] && command -v wl-copy >/dev/null 2>&1; then
    tee >(wl-copy)
  elif [ "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
    tee >(xclip -selection clipboard)
  else
    echo "No clipboard tool found (needs wl-copy or xclip)" >&2
    tee
  fi
}

vrun() {
  echo "=== $@ ==="
  "$@"
}

upgrade() {
  vrun sudo aptitude update &&
  vrun sudo aptitude upgrade &&
  vrun sudo snap refresh &&
  vrun cargo install-update -a
}

