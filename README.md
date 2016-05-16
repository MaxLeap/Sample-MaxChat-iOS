# Sample-MaxChat-iOS

使用方法
1、在maxleap.cn中创建app，记录appid和clientkey。

2、更换MaxChat-Prefix.pch中的宏定义为1中的appid和clientkey：
#define MAXLEAP_APPID           @"your_app_id"
#define MAXLEAP_CLIENTKEY       @"your_client_key"

3、如果要使用微博、QQ和微信第三方登录，需要先在相应的开发者后台注册app，输入正确的app信息。

4、更换MaxChat-Prefix.pch中的一下宏定义：
#define WECHAT_APPID            @"your_wechat_appid"
#define WECHAT_SECRET           @"your_wechat_secret"
#define WEIBO_APPKEY            @"your_weibo_appkey"
#define WEIBO_REDIRECTURL       @"your_weibo_redirect_url"
#define QQ_APPID                @"your_qq_appid"
