
�ړI
  Flex3SDK�̃I�����C��API�h�L�������g��Windows��HTML Help�ɕϊ�����B
  Adobe Livedocs�T�[�o�͍����ׂɂȂ�Ƃ���߂ă��X�|���X���������A������R���e���c��
  �z�M����̂ŁAFlex3���t�@�����X�̃y�[�W�X�i�b�v�V���b�g�����[�J���ۑ����Ďg�p����B

�K�v��
  Windows
  Ruby
  HTML Help Workshop

�菇
1.Livedocs�T�[�o�𑖍����ăR���e���c��ԗ��I�Ɏ擾����
  ruby download.rb livedocs.adobe.com /flex/3_jp/langref index.html langref

  ���̏�����Ctrl+C�Œ��f���Ă��A����ĊJ�����Ƃ��A���[�J���Ɏ擾�ς݁A
  ����сA�f�b�h�����N�Ƃ킩���Ă���URL�̓X�L�b�v����B

  === ���F�d�v ===
  �T�[�o��������R���e���c��Ԃ�����A����̃h�L�������g�ŋ}�ɉ�������������
  ���Ƃ�����̂ŁALivedocs�T�[�o�̒��q�������Ƃ��͒��~���A���΂炭�҂��Ă���
  �ĊJ���悤�B�T�[�o�����G���Ă���ƒ��q��������������Ȃ����A�T�[�o�ɂ����Ƃ�
  ���ׂ������Ă���͎̂������Ƃ������Ƃ�F�����A���ʂɉ{�����Ă��郆�[�U��
  �������낤�B

2.�����G���R�[�f�B���O��ShiftJIS�ɕϊ����A�I�t���C���p�ɕϊ�����html�ɃR�s�[���Ă���
  ruby preprocess-ja.rb langref html

3.�h�L�������g�c���[����͂��AHTML�w���v�v���W�F�N�g�ɕϊ�
  ruby createhhp-ja.rb flex3langref html "Adobe Flex 3 ���t�@�����X�K�C�h"

4.HTML�w���v�v���W�F�N�g���R���p�C��
  "C:\Program Files\HTML Help Workshop\hhc.exe" flex3langref.hhp

���C�Z���X
  GPL����

���
  �c���v�P tanakahisateru@gmail.com
