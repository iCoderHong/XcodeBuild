# iOS自动构建命令-XcodeBuild
[Apple官方文档](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html)
```
xcodebuild 是苹果发布自动构建的工具。
```
---
## xcrun PackageApplication方式
在Xcode升级到8.3已就过期了，如果还需要该方式构建需要如下工作

1.下载`PackageApplication`命令。

2.拷贝到下面目录
```ruby
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/
```
3.执行命令
```ruby
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/
chmod +x /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication
```
构建脚本
```ruby
#编译 链接 签名 生成app
#如果要构建workspace，你必须指定-workspace和-scheme参数。
xcodebuild \
-workspace "$ZWWorkspace/$ZWProjectName.xcodeproj/project.xcworkspace" \
-scheme "$ZWScheme" \
-configuration "$ZWConfiguration" \
clean \
build \
-derivedDataPath "$ZWBuildTempDir"
#CODE_SIGN_IDENTITY=证书
#PROVISIONING_PROFILE=描述文件UUID

#生成ipa  本质主要是对生成app进行压缩成ipa
xcrun -sdk iphoneos \
-v PackageApplication "$ZWBuildTempDir/Build/Products/$ZWConfiguration-iphoneos/$ZWProjectName.app" \
-o "$HCIpaDir/$ZWDate.ipa" #这里反复报错 如果输出的目录不存在就报错 Unable to create '....." 解决办法 手动穿件输出测文件夹层级结构

#清除构建的文件
rm -rf $ZWBuildDir/temp

open $HCIpaDir
```
![](https://github.com/coderketao/XcodeBuild/blob/master/TestProj/imags/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-03-06%20%E4%B8%8B%E5%8D%8810.06.31.png)

报警告建议使用`xcodebuild -exportArchive`构建

## xcodebuild -exportArchive方式
构建命令
```ruby
xcodebuild archive \
-workspace "$ZWWorkspace/$ZWProjectName.xcodeproj/project.xcworkspace" \
-scheme "$ZWScheme" \
-configuration "$ZWConfiguration" \
-archivePath "$ZWBuildTempDir/$ZWProjectName.xcarchive"
CODE_SIGN_IDENTITY="" #证书
PROVISIONING_PROFILE="" #描述文件UUID

xcodebuild \
-exportArchive \
-archivePath "$ZWBuildTempDir/$ZWProjectName.xcarchive" \
-exportPath "$HCIpaDir/$ZWDate/" \
-exportOptionsPlist "./exportOptionsPlist.plist" \
CODE_SIGN_IDENTITY=""
PROVISIONING_PROFILE="" #描述文件UUID
```
这里注意`-exportOptionsPlist`参数。

###将构建的包分发
```ruby
curl \
-F "file=@${FilePath}" \
-F "uKey=${UKey}" \
-F "_api_key=${ApiKey}" \
https://www.pgyer.com/apiv2/app/upload
```

###issue

![](https://github.com/coderketao/XcodeBuild/blob/master/TestProj/imags/Snip20180306_1.png)
解决办法：在`exportOptionsPlist.plist`关闭`Bitcode`为NO。







