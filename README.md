# PrivateNote

    互联网时代，我们每个人不知不觉中有了越来越多的账户和密码，有一些账户很长时间不用，等到用的时候才发现早已经忘记了……此项目的目的就是让我们能够方便、
快速、永久并且安全的保存这些个人信息。

设计思路：
1.打开APP需要验证独立密码或者面部识别（独立密码必须，面部识别可选）；
2.查看任何一条数据，每次都需要一次指纹识别；
3.可保存的数据为图片、录音、文本；
4.数据库的操作使用FMDB，进行数据库加密操作；
5.数据库随应用信息上传到iCloud，永久保存；
