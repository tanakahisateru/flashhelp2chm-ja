echo off
mkdir dw_cs3
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\HTML" ./dw_cs3/HTML
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\CSS" ./dw_cs3/CSS
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\JavaScript" ./dw_cs3/JavaScript
copy /Y josh.css .\dw_cs3\HTML
copy /Y josh.css .\dw_cs3\CSS
copy /Y josh.css .\dw_cs3\JavaScript
rem --���̏C���������I�Ɍ����u���ōs����--
rem echo .\dw_cs3\JavaScript\Reference.xml�ɂ͒v���I�Ȗ�肪����̂ŏC�����Ă�������
rem echo XML�����̔j�� /book/topic/subtopic(name="frame")
rem echo XML�����̔j�� /book/topic/subtopic(name="rules")
rem pause
rem echo �{���ɂł��܂�����
rem pause
ruby createhhp-ja.rb dwref_cs3 dw_cs3 "Adobe Dreamweaver CS3 ���t�@�����X�p�l��"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref_cs3.hhp
