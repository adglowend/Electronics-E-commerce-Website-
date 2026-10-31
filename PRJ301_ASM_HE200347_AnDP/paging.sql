USE LaptopStore;
GO
/*====================================================
    THÊM PRODUCT - LAPTOP (bổ sung)
====================================================*/
INSERT INTO Product
(CategoryID, BrandID, ProductName, Price, Quantity, Description)
SELECT
    (SELECT CategoryID FROM Category WHERE CategoryName = v.CategoryName),
    (SELECT BrandID FROM Brand WHERE BrandName = v.BrandName),
    v.ProductName, v.Price, v.Quantity, v.Description
FROM (VALUES
    (N'Laptop', 'Dell',    N'Dell Inspiron 15 3520',        16990000, 20, N'Dell Inspiron 15 Core i5 Gen 12, 8GB/512GB'),
    (N'Laptop', 'Dell',    N'Dell Alienware x14 R2',        62990000, 4,  N'Alienware x14 R2 Gaming Core i7 RTX 4060'),
    (N'Laptop', 'HP',      N'HP Omen 16',                   32990000, 7,  N'HP Omen 16 Gaming Core i7 RTX 4060'),
    (N'Laptop', 'HP',      N'HP Envy x360 14',              24990000, 9,  N'HP Envy x360 14 2-in-1 Core Ultra 5'),
    (N'Laptop', 'Asus',    N'Asus Zenbook 14 OLED',         26990000, 11, N'Asus Zenbook 14 OLED Core Ultra 7'),
    (N'Laptop', 'Asus',    N'Asus Vivobook 15',             15990000, 25, N'Asus Vivobook 15 Core i5 Gen 13'),
    (N'Laptop', 'Lenovo',  N'Lenovo Legion 5 Pro',          33990000, 8,  N'Lenovo Legion 5 Pro Gaming RTX 4060'),
    (N'Laptop', 'Lenovo',  N'Lenovo IdeaPad Slim 5',        17990000, 16, N'Lenovo IdeaPad Slim 5 Core i5 Gen 13'),
    (N'Laptop', 'Acer',    N'Acer Swift Go 14',             19990000, 14, N'Acer Swift Go 14 Core i5 Gen 13'),
    (N'Laptop', 'MSI',     N'MSI Prestige 14 Evo',          27990000, 6,  N'MSI Prestige 14 Evo Core Ultra 7'),
    (N'Laptop', 'Apple',   N'MacBook Pro 16 M3 Max',        89990000, 3,  N'Apple MacBook Pro 16 inch chip M3 Max')
) AS v(CategoryName, BrandName, ProductName, Price, Quantity, Description)
WHERE NOT EXISTS (SELECT 1 FROM Product p WHERE p.ProductName = v.ProductName);

/*====================================================
    THÊM PRODUCT IMAGE cho các laptop mới
====================================================*/
INSERT INTO ProductImage (ProductID, ImageURL, IsMain, DisplayOrder)
SELECT
    (SELECT ProductID FROM Product WHERE ProductName = v.ProductName),
    v.ImageURL, v.IsMain, v.DisplayOrder
FROM (VALUES
    (N'Dell Inspiron 15 3520',  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853', 1, 1),
    (N'Dell Alienware x14 R2',  'https://images.unsplash.com/photo-1603302576837-37561b2e2302', 1, 1),
    (N'HP Omen 16',             'https://images.unsplash.com/photo-1603302576837-37561b2e2302', 1, 1),
    (N'HP Envy x360 14',        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8', 1, 1),
    (N'Asus Zenbook 14 OLED',   'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed', 1, 1),
    (N'Asus Vivobook 15',       'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed', 1, 1),
    (N'Lenovo Legion 5 Pro',    'https://images.unsplash.com/photo-1603302576837-37561b2e2302', 1, 1),
    (N'Lenovo IdeaPad Slim 5',  'https://images.unsplash.com/photo-1517336714731-489689fd1ca8', 1, 1),
    (N'Acer Swift Go 14',       'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed', 1, 1),
    (N'MSI Prestige 14 Evo',    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8', 1, 1),
    (N'MacBook Pro 16 M3 Max',  'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9', 1, 1)
) AS v(ProductName, ImageURL, IsMain, DisplayOrder)
WHERE NOT EXISTS (
    SELECT 1 FROM ProductImage pi
    WHERE pi.ProductID = (SELECT ProductID FROM Product WHERE ProductName = v.ProductName)
);
GO

