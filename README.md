地址：[替换工具](https://github.com/ShaochongDu/FileReplaceProject.git)

该工程主要方便文件及文件内容替换，但mac中并未能修改文件夹名字，导致有些处理需手动操作

![iOS 工程及文件内容替换工具](https://upload-images.jianshu.io/upload_images/1186277-47f467470fc6fbf4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 替换普通文件及文件内容
1. 选择所需处理的文件夹
2. 选择处理的文件类型
  2.1 勾选已有类型
  2.2 自定义文件类型，文件后缀名以英文逗号分隔
3. 替换前后字符串填写
替换前字符串与替换后字符串个数必须相同，中间以英文逗号分隔
4. 替换类型
   4.1 全文替换：类似常用的替换功能；
   4.2 单词前缀替换：分为三类 
   ① iOS中以英文点做分隔的单词替换，如 self.ansproperty，针对ans替换 
   ② iOS中的set方法替换，如 setAnsProperty，针对Ans替换 
   ③ 普通的单词前缀替换， 如ansProperty，针对ans替换
5. 执行替换：即可异步执行
6. 查看执行日志

## 替换iOS工程名称注意
1. 替换类型 请使用全文替换
2. 由于文件夹无法重命名，需要手动修改文件夹名字
3. .xcodeproj/.xcworkspace/.xcdatamodeld等都需要手动修改，包括xxTests/xxUITests文件夹，因为他们是文件夹形式存在
4. 重命名完部分文件夹后，需要重新导入工程
5. 删除工程Build Phase中Copy Bundle Resource->info.plist文件链接（包括xxTests/xxUITests工程）
6. 重新clean并编译工程
    
## 替换文件及文件内容前缀
主要替换以xxx开头的单词，包括两个内容（不包括文件夹名称，对于中文可能存在系统切割问题，导致无法替换）：
1. 文件名每个单词的开头部分
2. 文件内容每个单词的开头部分



## todo
1. 目前mac中貌似无法修改文件夹名称（即使创建文件夹后再移动也没起作用）
2. iOS工程中文件内容替换没有使用正则，而是使用系统字符串方法将字符串切割成单词的方式，性能比较差，而且分隔中文单词可能跟想象中的不一致

以上两个问题如有人知道，请留言交流