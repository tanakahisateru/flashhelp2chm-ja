echo off
mkdir html
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./html/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./html/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./html/JavaScript
copy /Y josh.css .\html\HTML
copy /Y josh.css .\html\CSS
copy /Y josh.css .\html\JavaScript
echo .\html\JavaScript\Reference.xml�ɂ͒v���I�Ȗ�肪����̂ŏC�����Ă�������
echo XML�����̔j�� /book/topic/subtopic(name="frame")
echo XML�����̔j�� /book/topic/subtopic(name="rules")
pause
echo �{���ɂł��܂�����
pause
ruby createhhp-ja.rb ./html
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref.hhp
