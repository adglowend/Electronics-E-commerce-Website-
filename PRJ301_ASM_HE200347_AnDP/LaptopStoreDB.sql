CREATE DATABASE LaptopStore;
GO

USE LaptopStore;
GO

/*====================================================
    ROLE
====================================================*/
CREATE TABLE Role
(
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(30) NOT NULL UNIQUE,
    Description NVARCHAR(255),
    Status BIT NOT NULL DEFAULT 1
);

/*====================================================
    USERS
====================================================*/
CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(100) NOT NULL UNIQUE,

    PasswordHash VARCHAR(255) NOT NULL,

    Phone VARCHAR(20),

    Address NVARCHAR(255),

    RoleID INT NOT NULL DEFAULT 3, -- 1=Admin, 2=Staff, 3=Customer (mặc định khi đăng ký là Customer)

    Status BIT NOT NULL DEFAULT 0,

    ActivationToken VARCHAR(255) NULL,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_User_Role
        FOREIGN KEY(RoleID)
        REFERENCES Role(RoleID)
);

/*====================================================
    CATEGORY
====================================================*/
CREATE TABLE Category
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    CategoryName NVARCHAR(100) NOT NULL UNIQUE,

    Description NVARCHAR(255),

    Status BIT NOT NULL DEFAULT 1
);

/*====================================================
    BRAND
====================================================*/
CREATE TABLE Brand
(
    BrandID INT IDENTITY(1,1) PRIMARY KEY,

    BrandName NVARCHAR(100) NOT NULL UNIQUE,

    Country NVARCHAR(50),

    Status BIT NOT NULL DEFAULT 1
);

/*====================================================
    PRODUCT
====================================================*/
CREATE TABLE Product
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,

    CategoryID INT NOT NULL,

    BrandID INT NOT NULL,

    ProductName NVARCHAR(200) NOT NULL,

    Price DECIMAL(18,2) NOT NULL
        CHECK (Price >= 0),

    Quantity INT NOT NULL
        CHECK (Quantity >= 0),

    Description NVARCHAR(MAX),

    Status BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_Product_Category
        FOREIGN KEY(CategoryID)
        REFERENCES Category(CategoryID),

    CONSTRAINT FK_Product_Brand
        FOREIGN KEY(BrandID)
        REFERENCES Brand(BrandID)
);

/*====================================================
    PRODUCT IMAGE
====================================================*/
CREATE TABLE ProductImage
(
    ImageID INT IDENTITY(1,1) PRIMARY KEY,

    ProductID INT NOT NULL,

    ImageURL NVARCHAR(255) NOT NULL,

    IsMain BIT NOT NULL DEFAULT 0,

    DisplayOrder INT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_ProductImage_Product
        FOREIGN KEY(ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

/*====================================================
    CART
====================================================*/
CREATE TABLE Cart
(
    CartID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL UNIQUE,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Cart_User
        FOREIGN KEY(UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE
);

/*====================================================
    CART ITEM
====================================================*/
CREATE TABLE CartItem
(
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,

    CartID INT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL
        CHECK (Quantity > 0),

    CONSTRAINT FK_CartItem_Cart
        FOREIGN KEY(CartID)
        REFERENCES Cart(CartID)
        ON DELETE CASCADE,

    CONSTRAINT FK_CartItem_Product
        FOREIGN KEY(ProductID)
        REFERENCES Product(ProductID)
);

/*====================================================
    ORDERS
====================================================*/
CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,

    UserID INT NOT NULL,

    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),

    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,

    Status VARCHAR(30) NOT NULL
        DEFAULT 'Pending'
        CHECK
        (
            Status IN
            (
                'Pending',
                'Confirmed',
                'Shipping',
                'Completed',
                'Cancelled'
            )
        ),

    CONSTRAINT FK_Order_User
        FOREIGN KEY(UserID)
        REFERENCES Users(UserID)
);

/*====================================================
    ORDER DETAIL
====================================================*/
CREATE TABLE OrderDetail
(
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL
        CHECK (Quantity > 0),

    Price DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_OrderDetail_Order
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderDetail_Product
        FOREIGN KEY(ProductID)
        REFERENCES Product(ProductID)
);

/*====================================================
    PAYMENT
====================================================*/
CREATE TABLE Payment
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT NOT NULL UNIQUE,

    Method VARCHAR(20) NOT NULL
        CHECK (Method IN ('Cash', 'COD')),

    PaymentStatus VARCHAR(20) NOT NULL
        DEFAULT 'Pending'
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Cancelled')),

    PaymentDate DATETIME NULL,

    CONSTRAINT FK_Payment_Order
        FOREIGN KEY(OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);

/*====================================================
    INDEX
====================================================*/
CREATE INDEX IX_Product_Category
ON Product(CategoryID);

CREATE INDEX IX_Product_Brand
ON Product(BrandID);

CREATE INDEX IX_Product_Name
ON Product(ProductName);

CREATE INDEX IX_ProductImage_Product
ON ProductImage(ProductID);

CREATE INDEX IX_Order_User
ON Orders(UserID);

CREATE INDEX IX_OrderDetail_Order
ON OrderDetail(OrderID);

/*====================================================
    SAMPLE DATA
====================================================*/

-- Role
INSERT INTO Role(RoleName, Description)
VALUES
('Admin', N'Quản trị hệ thống'),
('Staff', N'Nhân viên'),
('Customer', N'Khách hàng');

-- Category
INSERT INTO Category(CategoryName, Description)
VALUES
(N'Laptop', N'Laptop'),
(N'Mouse', N'Gaming Mouse'),
(N'Keyboard', N'Mechanical Keyboard'),
(N'Monitor', N'Gaming Monitor');

-- Brand
INSERT INTO Brand(BrandName, Country)
VALUES
('Dell', 'USA'),
('HP', 'USA'),
('Asus', 'Taiwan'),
('Lenovo', 'China');

-- Users
INSERT INTO Users
(
    FullName,
    Email,
    PasswordHash,
    Phone,
    Address,
    RoleID
)
VALUES
(
    N'Administrator',
    'admin@gmail.com',
    '123456',
    '0900000000',
    N'Ha Noi',
    1
),
(
    N'Nguyen Van A',
    'customer@gmail.com',
    '123456',
    '0911111111',
    N'Ho Chi Minh',
    3
);

-- Product
INSERT INTO Product
(
    CategoryID,
    BrandID,
    ProductName,
    Price,
    Quantity,
    Description
)
VALUES
(
    1,
    1,
    N'Dell XPS 13',
    35990000,
    10,
    N'Dell XPS 13 Core Ultra 7'
),
(
    1,
    3,
    N'Asus ROG Zephyrus G14',
    42990000,
    5,
    N'Gaming Laptop Asus ROG'
);

-- Product Image
INSERT INTO ProductImage
(
    ProductID,
    ImageURL,
    IsMain,
    DisplayOrder
)
VALUES
(1,'https://laptopphuocdat.com/wp-content/uploads/2023/04/XPS-9320-i7-1-scaled.jpg',1,1),
(1,'https://sm.pcmag.com/t/pcmag_au/review/d/dell-xps-1/dell-xps-13-9350-core-ultra-2_p8pu.1200.jpg',0,2),
(2,'https://laptoptld.com/wp-content/uploads/2022/11/Dell-XPS-9310-i5-5-scaled.jpg',1,1);

-- Cart
INSERT INTO Cart(UserID)
VALUES (2);

-- Cart Item
INSERT INTO CartItem
(
    CartID,
    ProductID,
    Quantity
)
VALUES
(1,1,1),
(1,2,1);

-- Order
INSERT INTO Orders
(
    UserID,
    TotalAmount,
    Status
)
VALUES
(
    2,
    78980000,
    'Pending'
);

-- Order Detail
INSERT INTO OrderDetail
(
    OrderID,
    ProductID,
    Quantity,
    Price
)
VALUES
(1,1,1,35990000),
(1,2,1,42990000);

-- Payment
INSERT INTO Payment
(
    OrderID,
    Method,
    PaymentStatus
)
VALUES
(
    1,
    'COD',
    'Pending'
);