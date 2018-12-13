if did_filetype()
    finish
endif
if getline(1) =~# '^#!.*osascript -l JavaScript'
    setfiletype javascript
endif
