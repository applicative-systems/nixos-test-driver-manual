Output demo.gif

Set FontSize 20
Set Width 1200
Set Height 600

Hide

Type "export PS1='> ' && clear"
Enter
Wait

Show

Type "git remote -v"
Enter
Sleep 3s
Type "nix -L build .#test-cuda-nvidia"
Enter
Wait@100s
Sleep 10
