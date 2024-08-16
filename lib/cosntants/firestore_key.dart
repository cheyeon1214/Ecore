// Collection names
const COLLECTION_USERS = 'Users';
const COLLECTION_SELL_PRODUCTS = 'SellPosts';
const COLLECTION_DONA_PRODUCTS = 'DonaPosts';
const COLLECTION_MARKETS = 'Markets';

// Keys for USERS collection
const KEY_USERKEY = 'user_key';
const KEY_EMAIL = 'email';
const KEY_NAME = 'username';
const KEY_PROFILEIMG = 'profile_img';
const KEY_POINT = 'point';
const KEY_MYDONAPOST = 'my_dona_post';
const KEY_CART = 'cart'; // 장바구니 배열 값
const KEY_MARKETS = 'Markets';
const KEY_USER_MARKETID = 'marketId';


// Keys for SELL_PRODUCTS collection
const KEY_SELL_MARKETID = 'marketId'; // 외래키
const KEY_SELLID = 'sellId';
const KEY_SELLTITLE = 'title';
const KEY_SELLIMG = 'img';
const KEY_SELLPRICE = 'price';
const KEY_SELLCATEGORY = 'category';
const KEY_SELLBODY = 'body';
const KEY_SELL_CREATED_AT = 'createdAt';
const KEY_SELL_VIEW_COUNT = 'viewCount';

// Keys for DONA_PRODUCTS collection
const KEY_DONA_USERKEY = 'userId'; // 외래키
const KEY_DONAID = 'dona_id';
const KEY_DONATITLE = 'title';
const KEY_DONAIMG = 'img';
const KEY_DONAPRICE = 'price';
const KEY_DONACATEGORY = 'category';
const KEY_DONACOLOR = 'color';
const KEY_DONAMATERIAL = 'material';
const KEY_DONACONDITION = 'condition';
const KEY_DONABODY = 'body';
const KEY_DONA_CREATED_AT = 'createdAt';
const KEY_DONA_VIEW_COUNT = 'viewCount';

// Keys for MARKETS collection
const KEY_MARKETID = 'marketId';
const KEY_MARKET_USERKEY = 'userId';
const KEY_MARKET_NAME = 'name';
const KEY_MARKET_PROFILEIMG = 'img';
const KEY_MYSELLPOST = 'sellPosts';


//////////////////
const COLLECTION_POSTS='Posts';
const COLLECTION_COMMENTS = 'Comments';

const KEY_LIKEDPOSTS = ' likes posts';
const KEY_FOLLOWERS = 'followers';
const KEY_FOLLOWINGS = 'followings';
const KEY_MYPOSTS = 'my_posts';
const KEY_USERNAME = 'username';

const KEY_COMMENT = 'comment';
const KEY_COMMENTTIME = ' commenttime';

//////////////////
const COLLECTION_ORDERS = 'Orders';

const KEY_ORDERID = 'orderId';
const KEY_ORDERDATE = 'date';
const KEY_ORDERSTATUS = 'status';
const KEY_TOTALPRICE = 'totalPrice';
const KEY_ITEMS = 'items'; //주문 목록

const KEY_ITEMID = 'itemId';
const KEY_ORDERTITLE = 'title';
const KEY_ORDERIMG = 'img';
const KEY_ORDERPRICE = 'price';
const KEY_ITEMQUANTITY = 'quantity';