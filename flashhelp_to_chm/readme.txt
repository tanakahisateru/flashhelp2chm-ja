
�ړI
  Flash�̃w���v�p�l����Windows��HTML Help�ɕϊ�����B
  �Z�pQ&A�̂��߂�Flash���N������̂��ʓ|�B
  Web�T�C�g�̃��t�@�����X��Flash�̃w���v�p�l�����A�S�ʓI�ɏd���B

�K�v��
  Windows
  Ruby
  HTML Help Workshop

�菇
1.�����G���R�[�f�B���O��ShiftJIS�ɕϊ����Ahtml�t�H���_�ɃR�s�[����
  ruby preprocess-ja.rb <Flash��HelpPanel�t�H���_�̃p�X> html

  Flash��HelpPanel�t�H���_�̃p�X�̓f�t�H���g�ňȉ��̏ꏊ�ɂ���B
  Flash8:
  C:\Documents and Settings\All Users\Application Data\Macromedia\Flash 8\ja\Configuration\HelpPanel
  Flash CS3:
  C:\Documents and Settings\All Users\Application Data\Adobe\Flash CS3\ja\Configuration\HelpPanel

2.�I�v�V�����F�s�v�ȃh�L�������g�Z�b�g�����O����
  �����s�v�ȃh�L�������g�Z�b�g������ꍇ�A�ϊ��R�s�[����html�t�H���_���̕s�v�t�H���_���폜���Ă����܂�Ȃ��B
  FlashLite�̃h�L�������g�͕s�v�AAS3�֘A�̂݁A�ȂǁA�p�r�ɉ����č\���������O���邱�Ƃ��ł���B

3.�h�L�������g�c���[����͂��AHTML�w���v�v���W�F�N�g�ɕϊ�

  Flash8:
  ruby createhhp-ja.rb  flashhelp8 html "Macromedia Flash8 �w���v"
  Flash CS3:
  ruby createhhp-ja.rb  flashhelp_cs3 html "Adobe Flash CS3 �w���v"

4.HTML�w���v�v���W�F�N�g���R���p�C��
  "C:\Program Files\HTML Help Workshop\hhc.exe" flashhelp8.hhp

���C�Z���X
  GPL����

���
  �c���v�P htanaka@loop-net.co.jp
