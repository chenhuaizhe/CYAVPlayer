# CYAVPlayer
A Simple AVPlayer For Development 


> 公司需要在app中简单用一段视频介绍公司的产品，本来打算直接链接优酷上的html页面，但考虑到流畅度问题，于是还是决定用iOS原生的。本来以为很简单，三下五除二就写完了MPMoviePlayer的代码，后来想起来了，在iOS 9.0中，这个类被废弃了。于是在网上自己找了一个AVPlayer的Demo，自己简单整理了一下，希望能做到的是：以后要用直接拖过来就能用。

####导入方法
*  #####下载工程 <a href = 'https://github.com/gangverk/GVMusicPlayerController.git'>https://github.com/gangverk/GVMusicPlayerController.git</a>
*  #####导入类库 
<pre><code>AVFoundation.framework</code></pre>
*  #####在下载的工程中找到<em>movie</em>文件夹，拖到你的工程中
*  #####在你要用到的类中导入头文件
<pre><code>#import"PlayerViewController.h" </code></pre>

*  #####进入视频播放页，请一定要设置一个可以播放的<em>videoURLString</em>

```objective-c
PlayerViewController *pvc = [PlayerViewController new];
    pvc.videoURLString = @"这里用你要播放的视频url";
    [self.navigationController pushViewController:pvc animated:YES];
'''
    
<p>如果你用的是http请求，请在info.plist文件里添加以下代码来允许http请求：</p>
'''xml    
   <key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
              </dict>
'''              
    
                   

   


