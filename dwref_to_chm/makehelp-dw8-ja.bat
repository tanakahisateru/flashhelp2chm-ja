echo off
mkdir html
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./html/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./html/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./html/JavaScript
copy /Y josh.css .\html\HTML
copy /Y josh.css .\html\CSS
copy /Y josh.css .\html\JavaScript
echo .\html\JavaScript\Reference.xmlには致命的な問題があるので修正してください
echo XML書式の破損 /book/topic/subtopic(name="frame")
echo XML書式の破損 /book/topic/subtopic(name="rules")
pause
echo 本当にできましたか
pause
ruby createhhp-ja.rb ./html
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref.hhp
