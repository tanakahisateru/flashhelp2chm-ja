echo off
mkdir html
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./html/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./html/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./html/JavaScript
copy /Y josh.css .\html\HTML
copy /Y josh.css .\html\CSS
copy /Y josh.css .\html\JavaScript
rem --���̏C���������I�Ɍ����u���ōs����--
rem echo .\html\JavaScript\Reference.xml�ɂ͒v���I�Ȗ�肪����̂ŏC�����Ă�������
rem echo XML�����̔j�� /book/topic/subtopic(name="frame")
rem echo XML�����̔j�� /book/topic/subtopic(name="rules")
rem pause
rem echo �{���ɂł��܂�����
rem pause
ruby createhhp-ja.rb ./html
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref.hhp
