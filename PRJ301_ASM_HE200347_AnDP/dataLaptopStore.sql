USE LaptopStore;
GO

/*====================================================
    THÊM BRAND (bỏ qua nếu đã tồn tại)
====================================================*/
INSERT INTO Brand(BrandName, Country)
SELECT v.BrandName, v.Country
FROM (VALUES
    ('Apple', 'USA'),
    ('Acer', 'Taiwan'),
    ('MSI', 'Taiwan'),
    ('Logitech', 'Switzerland'),
    ('Corsair', 'USA'),
    ('Samsung', 'South Korea')
) AS v(BrandName, Country)
WHERE NOT EXISTS (SELECT 1 FROM Brand b WHERE b.BrandName = v.BrandName);

/*====================================================
    THÊM CATEGORY (bỏ qua nếu đã tồn tại)
====================================================*/
INSERT INTO Category(CategoryName, Description)
SELECT v.CategoryName, v.Description
FROM (VALUES
    (N'Headset', N'Gaming Headset'),
    (N'Laptop Bag', N'Balo, túi chống sốc laptop')
) AS v(CategoryName, Description)
WHERE NOT EXISTS (SELECT 1 FROM Category c WHERE c.CategoryName = v.CategoryName);

/*====================================================
    THÊM USERS (bỏ qua nếu email đã tồn tại)
====================================================*/
INSERT INTO Users
(FullName, Email, PasswordHash, Phone, Address, RoleID, Status)
SELECT v.FullName, v.Email, v.PasswordHash, v.Phone, v.Address, v.RoleID, v.Status
FROM (VALUES
    (N'Tran Thi B',  'staff01@gmail.com',   '123456', '0922222222', N'Da Nang',    2, 1),
    (N'Le Van C',    'customer2@gmail.com', '123456', '0933333333', N'Ha Noi',     3, 1),
    (N'Pham Thi D',  'customer3@gmail.com', '123456', '0944444444', N'Can Tho',    3, 1),
    (N'Hoang Van E', 'customer4@gmail.com', '123456', '0955555555', N'Hai Phong',  3, 0)
) AS v(FullName, Email, PasswordHash, Phone, Address, RoleID, Status)
WHERE NOT EXISTS (SELECT 1 FROM Users u WHERE u.Email = v.Email);

/*====================================================
    THÊM PRODUCT (bỏ qua nếu ProductName đã tồn tại)
    Tra CategoryID / BrandID theo tên, không dùng số cứng
====================================================*/
INSERT INTO Product
(CategoryID, BrandID, ProductName, Price, Quantity, Description)
SELECT
    (SELECT CategoryID FROM Category WHERE CategoryName = v.CategoryName),
    (SELECT BrandID FROM Brand WHERE BrandName = v.BrandName),
    v.ProductName, v.Price, v.Quantity, v.Description
FROM (VALUES
    (N'Laptop', 'HP',       N'HP Pavilion 15',              18990000, 15, N'HP Pavilion 15 Core i5 Gen 13'),
    (N'Laptop', 'Lenovo',   N'Lenovo ThinkPad X1 Carbon',   45990000, 8,  N'Lenovo ThinkPad X1 Carbon Gen 11'),
    (N'Laptop', 'Apple',    N'MacBook Air M3',              28990000, 12, N'Apple MacBook Air chip M3 13 inch'),
    (N'Laptop', 'Apple',    N'MacBook Pro 14 M3 Pro',       58990000, 6,  N'Apple MacBook Pro 14 inch chip M3 Pro'),
    (N'Laptop', 'Acer',     N'Acer Nitro 5',                22990000, 10, N'Acer Nitro 5 Gaming Laptop RTX 3050'),
    (N'Laptop', 'MSI',      N'MSI Gaming GF63',             19990000, 9,  N'MSI GF63 Thin Gaming Laptop'),
    (N'Mouse',  'Logitech', N'Logitech G102',               350000,   50, N'Chuột chơi game Logitech G102 Lightsync'),
    (N'Mouse',  'Logitech', N'Logitech MX Master 3S',       2390000,  20, N'Chuột văn phòng cao cấp Logitech MX Master 3S'),
    (N'Mouse',  'Corsair',  N'Corsair Dark Core RGB Pro',   1590000,  15, N'Chuột gaming không dây Corsair Dark Core RGB Pro'),
    (N'Keyboard','Logitech',N'Logitech G Pro X',            2190000,  18, N'Bàn phím cơ Logitech G Pro X hotswap'),
    (N'Keyboard','Corsair', N'Corsair K70 RGB Pro',         3290000,  10, N'Bàn phím cơ Corsair K70 RGB Pro'),
    (N'Monitor','Samsung',  N'Samsung Odyssey G5 27"',       6990000,  14, N'Màn hình cong gaming Samsung Odyssey G5 27 inch 144Hz'),
    (N'Monitor','Asus',     N'Asus TUF Gaming VG27AQ',       7590000,  11, N'Màn hình Asus TUF Gaming VG27AQ 27 inch 165Hz'),
    (N'Headset','Logitech', N'Logitech G435',                1290000,  25, N'Tai nghe gaming không dây Logitech G435'),
    (N'Headset','Corsair',  N'Corsair HS55',                 1490000,  20, N'Tai nghe gaming Corsair HS55 Surround'),
    (N'Laptop Bag','Asus',  N'Balo Asus ROG Ranger BP2500',  890000,   30, N'Balo laptop chống sốc Asus ROG Ranger BP2500')
) AS v(CategoryName, BrandName, ProductName, Price, Quantity, Description)
WHERE NOT EXISTS (SELECT 1 FROM Product p WHERE p.ProductName = v.ProductName);

/*====================================================
    THÊM PRODUCT IMAGE (tra ProductID theo ProductName)
    Chỉ thêm nếu sản phẩm đó chưa có ảnh nào
====================================================*/
INSERT INTO ProductImage (ProductID, ImageURL, IsMain, DisplayOrder)
SELECT
    (SELECT ProductID FROM Product WHERE ProductName = v.ProductName),
    v.ImageURL, v.IsMain, v.DisplayOrder
FROM (VALUES
    (N'HP Pavilion 15',              'https://images.unsplash.com/photo-1517336714731-489689fd1ca8', 1, 1),
    (N'Lenovo ThinkPad X1 Carbon',   'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed', 1, 1),
    (N'MacBook Air M3',              'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9', 1, 1),
    (N'MacBook Pro 14 M3 Pro',       'https://images.unsplash.com/photo-1517336714731-489689fd1ca8', 1, 1),
    (N'Acer Nitro 5',                'https://images.unsplash.com/photo-1603302576837-37561b2e2302', 1, 1),
    (N'MSI Gaming GF63',             'https://images.unsplash.com/photo-1602080858428-57174f9431cf', 1, 1),
    (N'Logitech G102',               'https://images.unsplash.com/photo-1527814050087-3793815479db', 1, 1),
    (N'Logitech MX Master 3S',       'https://images.unsplash.com/photo-1527814050087-3793815479db', 1, 1),
    (N'Corsair Dark Core RGB Pro',   'https://images.unsplash.com/photo-1527814050087-3793815479db', 1, 1),
    (N'Logitech G Pro X',            'https://images.unsplash.com/photo-1595044426077-d36d9236d54a', 1, 1),
    (N'Corsair K70 RGB Pro',         'https://images.unsplash.com/photo-1595044426077-d36d9236d54a', 1, 1),
    (N'Samsung Odyssey G5 27"',      'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf', 1, 1),
    (N'Asus TUF Gaming VG27AQ',      'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf', 1, 1),
    (N'Logitech G435',               'https://images.unsplash.com/photo-1599669454699-248893623440', 1, 1),
    (N'Corsair HS55',                'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3', 1, 1)
) AS v(ProductName, ImageURL, IsMain, DisplayOrder)
WHERE NOT EXISTS (
    SELECT 1 FROM ProductImage pi
    WHERE pi.ProductID = (SELECT ProductID FROM Product WHERE ProductName = v.ProductName)
);

/*====================================================
    THÊM CART cho user chưa có giỏ hàng
    (Cart.UserID là UNIQUE nên mỗi user chỉ có 1 Cart)
====================================================*/
INSERT INTO Cart (UserID)
SELECT u.UserID
FROM Users u
WHERE u.Email IN ('customer2@gmail.com', 'customer3@gmail.com')
  AND NOT EXISTS (SELECT 1 FROM Cart c WHERE c.UserID = u.UserID);

/*====================================================
    THÊM CART ITEM (tra CartID qua Email, ProductID qua ProductName)
====================================================*/
INSERT INTO CartItem (CartID, ProductID, Quantity)
SELECT
    (SELECT c.CartID FROM Cart c JOIN Users u ON u.UserID = c.UserID WHERE u.Email = v.Email),
    (SELECT ProductID FROM Product WHERE ProductName = v.ProductName),
    v.Quantity
FROM (VALUES
    ('customer2@gmail.com', N'Acer Nitro 5', 1),
    ('customer2@gmail.com', N'Corsair Dark Core RGB Pro', 2),
    ('customer3@gmail.com', N'MacBook Air M3', 1),
    ('customer3@gmail.com', N'Corsair HS55', 1)
) AS v(Email, ProductName, Quantity);

/*====================================================
    THÊM ORDERS + ORDER DETAIL + PAYMENT
    Dùng biến SCOPE_IDENTITY() để không phụ thuộc ID có sẵn
====================================================*/
DECLARE @OrderID INT;

-- Order 1: Le Van C mua Acer Nitro 5
INSERT INTO Orders (UserID, TotalAmount, Status)
SELECT UserID, 22990000, 'Confirmed' FROM Users WHERE Email = 'customer2@gmail.com';
SET @OrderID = SCOPE_IDENTITY();

INSERT INTO OrderDetail (OrderID, ProductID, Quantity, Price)
SELECT @OrderID, ProductID, 1, 22990000 FROM Product WHERE ProductName = N'Acer Nitro 5';

INSERT INTO Payment (OrderID, Method, PaymentStatus, PaymentDate)
VALUES (@OrderID, 'COD', 'Pending', NULL);

-- Order 2: Pham Thi D mua Lenovo ThinkPad X1 Carbon
INSERT INTO Orders (UserID, TotalAmount, Status)
SELECT UserID, 45990000, 'Shipping' FROM Users WHERE Email = 'customer3@gmail.com';
SET @OrderID = SCOPE_IDENTITY();

INSERT INTO OrderDetail (OrderID, ProductID, Quantity, Price)
SELECT @OrderID, ProductID, 1, 45990000 FROM Product WHERE ProductName = N'Lenovo ThinkPad X1 Carbon';

INSERT INTO Payment (OrderID, Method, PaymentStatus, PaymentDate)
VALUES (@OrderID, 'COD', 'Pending', NULL);

-- Order 3: Nguyen Van A mua Samsung Odyssey G5 (đã hoàn thành, đã thanh toán)
INSERT INTO Orders (UserID, TotalAmount, Status)
SELECT UserID, 6990000, 'Completed' FROM Users WHERE Email = 'customer@gmail.com';
SET @OrderID = SCOPE_IDENTITY();

INSERT INTO OrderDetail (OrderID, ProductID, Quantity, Price)
SELECT @OrderID, ProductID, 1, 6990000 FROM Product WHERE ProductName = N'Samsung Odyssey G5 27"';

INSERT INTO Payment (OrderID, Method, PaymentStatus, PaymentDate)
VALUES (@OrderID, 'Cash', 'Paid', GETDATE());

-- Order 4: Le Van C mua Logitech G102 (đã hủy)
INSERT INTO Orders (UserID, TotalAmount, Status)
SELECT UserID, 350000, 'Cancelled' FROM Users WHERE Email = 'customer2@gmail.com';
SET @OrderID = SCOPE_IDENTITY();

INSERT INTO OrderDetail (OrderID, ProductID, Quantity, Price)
SELECT @OrderID, ProductID, 1, 350000 FROM Product WHERE ProductName = N'Logitech G102';

INSERT INTO Payment (OrderID, Method, PaymentStatus, PaymentDate)
VALUES (@OrderID, 'COD', 'Cancelled', NULL);

GO