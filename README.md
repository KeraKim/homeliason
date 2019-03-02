# homeliason

### client routing table
page name | URL | routing group
---- | --- | ---
index | / | Root Group
index | /index | Root Group
intro | /intro | Menus Group
notices | /notices | Menus Group
faqs | /faqs | Menus Group
qna | /qna | Menus Group
terms | /terms | Menus Group
portfolios | /portfolios | Contents Group
portfolio | /portfolios/:id | Contents Group
product | /products/:id | Contents Group
designers | /designers | Contents Group
designer | /designers/:id | Contents Group
events | /events | Marketings Group
application | /application | Users Group
signup | /signup | Users Group
login | /login | Users Group
findPassword | /findPassword | Users Group
resetPassword | /resetPassword | Users Group
result | /result/:param | Root Group
orders | /orders | Adjustments Group
qnas | /qnas | Monitorings Group
myProfile | /myProfile | Users Group
dropOut | /dropOut | Users Group

### admin / designer routing table
page name | URL | user | routing group
---- | --- | --- | ---
news | / | designer | Root Group
notices | / | admin | Root Group
news | /news | designer | Menus Group
userGuide | /userGuide | designer | Menus Group
editDesignerProfile | /designerProfile/edit | designer | Profile Group
editCompanyProfile | /companyProfile/edit | designer | Profile Group
managers | /managers | designer | Profile Group
addManager | /managers/add | designer | Profile Group
editManager | /managers/:id | designer | Profile Group
editSns | /sns/edit | designer | Profile Group
editAccount | /account/edit | designer | Profile Group
portfolios | /portfolios | designer / admin | Contents Group
addPortfolio | /portfolios/add | designer | Contents Group
editPortfolio | /portfolios/:id | designer | Contents Group
products | /products | designer / admin | Contents Group
addProduct | /products/add | designer | Contents Group
editProduct | /products/:id | designer | Contents Group
schedule | /schedule | designer | Contents Group
sales | /sales | designer / admin | Adjustments Group
adjustments | /adjustments | designer / admin | Adjustments Group
qnas | /qnas | designer / admin | Monitorings Group
designerQnas | /designerQnas | designer / admin | Monitorings Group
complainReview | /complainReview/add | designer | Monitorings Group
applyEvent | /applyEvent/add | designer | Monitorings Group
notices | /notices | admin | Menus Group
addNotice | /notices/add | admin | Menus Group
editNotice | /notices/:id | admin | Menus Group
faqs | /faqs | admin | Menus Group
addFaq | /faqs/add | admin | Menus Group
editFaq | /faqs/:id | admin | Menus Group
terms | /terms | admin | Menus Group
designers | /designers | admin | Users Group
users | /users | admin | Users Group
reviews | /reviews | admin | Monitorings Group
events | /events | admin | Marketings Group
addEvent | /events/add | admin | Marketings Group
editEvent | /events/:id | admin | Marketings Group
tags | /tags | admin | Marketings Group

