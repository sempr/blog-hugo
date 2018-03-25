---
title: "Mongodb的count不走索引的问题及解决"
date: 2017-06-25T16:16:32+08:00
---

线上有个用户访问我们站点一直超时，sentry记录了挂在了这么一行操作上`db.XXXX.count({xx:yy})`，这个看着挺奇怪的，`xx`这个字段我明明是加过索引的啊，怎么会没走这个索引呢。用explain调试的时候也说正常走了那个索引的，实际上并不像是正常走了的样子。

直到看到了[这里](https://docs.mongodb.com/manual/reference/method/cursor.count/#definition)

count操作居然支持一个叫做hint的操作，可以指定使用哪个索引，加上hint之后，这个结果居然可以秒出，不加就要消耗非常久的时候，久到30秒还跑不完的情况，总是感觉似乎他是跑去扫了个全表。

本以为这些知名的数据库啊，开源软件啊，可以信任的程度是蛮高的，但实际上也时不时的被各种坑一把，hint这个参数估计应该也是他们处理不好这样的问题而提供的临时替代方案吧，我自动的选索引搞不好我可以提供一个口子让你手动选啊…… 好有道理的样子