#KDSNetwork 说明文档

0、该网络层框架，是基于AFNetworking的二次封装

1、设计思路：
    1.1>基本的思想是`把每一个网络请求封装成对象`。
        每个 BaseRequest 对象，包含请求的各种信息：请求request、参数、connection、operation、返回值

    1.2>所以使用 KDSNetwork，你的`每一个请求都需要继承KDS_BaseRequest类`，通过覆盖父类的一些方法来构造指定的网络请求。

    1.3>为了命名规范，请将每一个继承自KDS_BaseRequest的类，按照以下命名格式
        KDS_ + [具体业务] + Request.h
        eg:  KDS_HangQiRequest.h

2、使用方法：

    1.4>并在 KDS_HangQiRequest.h 中提供一个便利构造方法的接口：
        eg:
- (instancetype)initWithModel: (id)model;

            方便的传入请求参数
        请求url、请求返回值的处理，在KDS_HangQiRequest.m 中 重写父类方法中具体处理
    1.5>

        


1、使用方法：
    ·同时支持delegate、block
    ·支持对请求的缓存
    ·支持断点续传
    ·……

2、



//  TODO: 
1、请求失败自动重试的支持
2、    
