#!/bin/bash

ZWProjectName="TestProj"
ZWScheme="TestProj"
ZWConfiguration="Release"

ZWDate=`date +%Y%m%d_%H%M`
ZWWorkspace=`pwd`
echo "workspace=$ZWWorkspace-----------------------"
ZWBuildDir="$ZWWorkspace/build"        #build路径
ZWBuildTempDir="$ZWBuildDir/temp/$ZWDate"    #构建过程中的文件
HCIpaDir="$ZWBuildDir/ipa"                                #生成ipa文件路径

:<<!
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
!

#-------PackageApplication已经不推荐使用了 warning: PackageApplication is deprecated, use `xcodebuild -exportArchive` instead.-----

xcodebuild archive \
-workspace "$ZWWorkspace/$ZWProjectName.xcodeproj/project.xcworkspace" \
-scheme "$ZWScheme" \
-configuration "$ZWConfiguration" \
-archivePath "$ZWBuildTempDir/$ZWProjectName.xcarchive"
CODE_SIGN_IDENTITY="iPhone Distribution: 孝远 杨 (NKW67GFDHM)" #证书
PROVISIONING_PROFILE="7f5477ac-67af-487e-b1e1-292e6402a2b6" #描述文件UUID

xcodebuild \
-exportArchive \
-archivePath "$ZWBuildTempDir/$ZWProjectName.xcarchive" \
-exportPath "$HCIpaDir/$ZWDate/" \
-exportOptionsPlist "./exportOptionsPlist.plist" \
CODE_SIGN_IDENTITY="iPhone Distribution: 孝远 杨 (NKW67GFDHM)"
PROVISIONING_PROFILE="7f5477ac-67af-487e-b1e1-292e6402a2b6" #描述文件UUID

#这里不需要设置证书
#编译流程
#1.首先看ZWConfiguration是Release还是Debug
#2.如果是Release那么就去General->Signing(Release)的Provisioning Profile编译
#3.如果是Debug那么就去General->Signing(Debug)的Provisioning Profile编译

#如果是发布store的包 只需将配置设置General->Signing(Release)的Provisioning Profile选择Store 描述文件

:<<!
    编写过程遇到的报错：
    1.exportOptionsPlist.plist文件的编写
        xcode直接先Archive 拿到ExportOptions.plist
    2.下面这个报错纠结了我好久，

#    Error Domain=NSCocoaErrorDomain Code=384
# 详细报错
#2018-03-06 17:18:43.013 xcodebuild[2836:4964380] [MT] IDEDistribution: -[IDEDistributionLogging _createLoggingBundleAtPath:]: Created bundle at path '/var/folders/rj/k7nnqyqd5xz7_lh9s2dc9z4m0000gn/T/TestProj_2018-03-06_17-18-43.012.xcdistributionlogs'.
#2018-03-06 17:18:43.476 xcodebuild[2836:4964380] [MT] IDEDistribution: Step failed: <IDEDistributionPackagingStep: 0x7f8ca5d414e0>: Error Domain=NSCocoaErrorDomain Code=3840 "No value." UserInfo={NSDebugDescription=No value., NSFilePath=/var/folders/rj/k7nnqyqd5xz7_lh9s2dc9z4m0000gn/T/ipatool-json-filepath-U38ZKM}
#error: exportArchive: The data couldn’t be read because it isn’t in the correct format.

#Error Domain=NSCocoaErrorDomain Code=3840 "No value." UserInfo={NSDebugDescription=No value., NSFilePath=/var/folders/rj/k7nnqyqd5xz7_lh9s2dc9z4m0000gn/T/ipatool-json-filepath-U38ZKM}

#** EXPORT FAILED **

#  最终发现了问题关闭compileBitcode 设置为NO
!

#通过蒲公英提供的上传应用 API，调用系统的 curl 命令来上传应用。
FilePath="$HCIpaDir/$ZWDate/${ZWScheme}.ipa"
UKey="013cca42bc5347715f895cfc8061f75f" #开发者的用户 Key，在应用管理-API中查看
ApiKey="4861c59806712e3473c867520884236f" #是开发者的 API Key，在应用管理-API中查看 注意不是APPKey

#chmod -R 777 "${FilePath}"
curl \
-F "file=@${FilePath}" \
-F "uKey=${UKey}" \
-F "_api_key=${ApiKey}" \
https://www.pgyer.com/apiv2/app/upload






