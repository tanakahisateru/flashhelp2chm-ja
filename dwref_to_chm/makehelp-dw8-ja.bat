echo off
mkdir dw8
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./dw8/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./dw8/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./dw8/JavaScript
copy /Y josh.css .\dw8\HTML
copy /Y josh.css .\dw8\CSS
copy /Y josh.css .\dw8\JavaScript
rem --���̏C���������I�Ɍ����u���ōs����--
rem echo .\dw8\JavaScript\Reference.xml�ɂ͒v���I�Ȗ�肪����̂ŏC�����Ă�������
rem echo XML�����̔j�� /book/topic/subtopic(name="frame")
rem echo XML�����̔j�� /book/topic/subtopic(name="rules")
rem pause
rem echo �{���ɂł��܂�����
rem pause
ruby createhhp-ja.rb dwref8 dw8 "Macromedia Dreamweaver8 ���t�@�����X�p�l��"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref8.hhp
