地址：[文件替换/删除工具](https://github.com/ShaochongDu/FileReplaceProject.git)

该工程主要功能为：文件重命名、文件内容替换以及文件删除功能

![mac 下文件替换及删除工具](https://upload-images.jianshu.io/upload_images/1186277-f791f8dcfd12f0c8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 配置介绍
1. 选择所需处理的文件夹
2. 选择处理的文件类型
    * 勾选已有类型
    * 自定义文件类型，文件后缀名以英文逗号分隔
3. 若为文件替换功能，则：
    * 替换前后字符串填写
   * 替换前字符串与替换后字符串个数必须相同，中间以英文逗号分隔
4. 文件处理类型
   * 全文替换：类似常用的替换功能；
   * 单词前缀替换：分为三类 
   ① iOS中以英文点做分隔的单词替换，如 self.ansproperty，针对ans替换 
   ② iOS中的set方法替换，如 setAnsProperty，针对Ans替换 
   ③ 普通的单词前缀替换， 如ansProperty，针对ans替换
   * 文件删除：删除指定类型的文件
5. 操作类型
   * 查询文件：在执行文件操作前可先查询所要处理的文件
   * 文件删除：执行删除文件操作
6. 查看执行日志

## 替换操作
### 替换iOS工程注意
1. 支持整个工程替换，无需其他操作
2. 建议使用“单词前缀替换”，防止某些系统关键字中包含替换内容，导致编译失败
3. 重新编译看是否可通过（某些变量替换后可能会有冲突，注意解决）
    
### 替换文件及文件内容前缀
主要替换以xxx开头的单词，包括两个内容（对于中文可能存在系统切割问题，导致无法替换）：
1. 文件名每个单词的开头部分
2. 文件内容每个单词的开头部分

## 删除文件
1. 目前仅支持删除文件，不包含对应文件夹操作

## todo
1. iOS工程中文件内容替换没有使用正则，而是使用系统字符串方法将字符串切割成单词的方式，性能比较差，而且分隔中文单词可能跟想象中的不一致

以上问题如有人了解，请留言交流