# Database Schema Documentation - Social App

## Tổng quan

Dựa trên phân tích code của project, đây là thiết kế cơ sở dữ liệu hoàn chỉnh cho ứng dụng mạng xã hội với các chức năng:
- Đăng nhập/Đăng ký người dùng
- Tạo và quản lý bài viết (posts)
- Like/Unlike bài viết và comment
- Bình luận (comments)
- Upload và quản lý hình ảnh
- Phân trang (pagination)

## API Endpoints Đã Phân Tích

### Authentication
- `POST /auth/login` - Đăng nhập
- `POST /auth/register` - Đăng ký

### Posts
- `GET /posts` - Lấy danh sách bài viết
- `GET /posts/:id` - Lấy chi tiết bài viết
- `POST /posts` - Tạo bài viết mới
- `POST /posts/:id/like` - Like bài viết
- `POST /posts/:id/unlike` - Unlike bài viết

### Comments
- `GET /posts/:postId/comments` - Lấy danh sách comment của bài viết
- `POST /posts/:postId/comments` - Tạo comment mới
- `POST /comments/:id/like` - Like comment
- `POST /comments/:id/unlike` - Unlike comment

### Upload
- `POST /upload` - Upload hình ảnh

---

## Firebase Firestore Schema

### 1. Collection: `users`

```
users (collection)
├── {userId} (document)
    ├── id: string
    ├── username: string
    ├── first_name: string
    ├── last_name: string
    ├── email: string
    ├── password_hash: string (hashed)
    ├── bio: string (optional)
    ├── is_verified: boolean (default: false)
    ├── avatar: map
    │   ├── url: string
    │   ├── org_url: string
    │   ├── org_width: number
    │   ├── org_height: number
    │   └── cloud_name: string
    ├── created_at: timestamp
    └── updated_at: timestamp
```

**Indexes:**
- `username` (ascending)
- `email` (ascending)

---

### 2. Collection: `posts`

```
posts (collection)
├── {postId} (document)
    ├── id: string
    ├── user_id: string (reference to users)
    ├── title: string
    ├── description: string
    ├── status: number (0=draft, 1=published, 2=deleted)
    ├── images: array of maps
    │   ├── url: string
    │   ├── org_url: string
    │   ├── org_width: number
    │   ├── org_height: number
    │   └── cloud_name: string
    ├── photos: array of maps (similar to images)
    ├── comment_counts: number
    ├── like_counts: number
    ├── created_at: timestamp
    └── updated_at: timestamp
```

**Indexes:**
- `user_id` (ascending)
- `created_at` (descending)
- `status` (ascending) + `created_at` (descending) - composite index

---

### 3. Collection: `comments`

```
comments (collection)
├── {commentId} (document)
    ├── id: string
    ├── post_id: string (reference to posts)
    ├── user_id: string (reference to users)
    ├── content: string
    ├── status: number
    ├── like_count: number
    ├── created_at: timestamp
    └── updated_at: timestamp
```

**Indexes:**
- `post_id` (ascending) + `created_at` (ascending) - composite index
- `user_id` (ascending)

---

### 4. Collection: `post_likes`

```
post_likes (collection)
├── {likeId} (document)
    ├── id: string
    ├── post_id: string (reference to posts)
    ├── user_id: string (reference to users)
    └── created_at: timestamp
```

**Indexes:**
- `post_id` (ascending) + `user_id` (ascending) - composite index (unique)
- `user_id` (ascending)

---

### 5. Collection: `comment_likes`

```
comment_likes (collection)
├── {likeId} (document)
    ├── id: string
    ├── comment_id: string (reference to comments)
    ├── user_id: string (reference to users)
    └── created_at: timestamp
```

**Indexes:**
- `comment_id` (ascending) + `user_id` (ascending) - composite index (unique)
- `user_id` (ascending)

---

### 6. Collection: `categories`

```
categories (collection)
├── {categoryId} (document)
    ├── id: string
    ├── title: string
    ├── description: string
    ├── photos: array
    ├── is_category: boolean
    ├── created_at: timestamp
    └── updated_at: timestamp
```

---

### 7. Collection: `auth_tokens`

```
auth_tokens (collection)
├── {tokenId} (document)
    ├── user_id: string (reference to users)
    ├── access_token: string
    ├── refresh_token: string
    ├── oauth_id: string (optional)
    ├── expires_in: number (seconds)
    ├── created_at: timestamp
    └── expires_at: timestamp
```

**Indexes:**
- `user_id` (ascending)
- `access_token` (ascending)
- `refresh_token` (ascending)

---


```sql
-- Users table
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url VARCHAR(500),
    avatar_org_url VARCHAR(500),
    avatar_org_width INT,
    avatar_org_height INT,
    avatar_cloud_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- Posts table
CREATE TABLE posts (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    title VARCHAR(500),
    description TEXT,
    status INT DEFAULT 1,
    comment_counts INT DEFAULT 0,
    like_counts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at DESC),
    INDEX idx_status_created (status, created_at DESC)
);

-- Post images table
CREATE TABLE post_images (
    id VARCHAR(255) PRIMARY KEY,
    post_id VARCHAR(255) NOT NULL,
    url VARCHAR(500) NOT NULL,
    org_url VARCHAR(500),
    org_width INT,
    org_height INT,
    cloud_name VARCHAR(100),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id)
);

-- Comments table
CREATE TABLE comments (
    id VARCHAR(255) PRIMARY KEY,
    post_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status INT DEFAULT 1,
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_post_created (post_id, created_at),
    INDEX idx_user_id (user_id)
);

-- Post likes table
CREATE TABLE post_likes (
    id VARCHAR(255) PRIMARY KEY,
    post_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_post_like (post_id, user_id),
    INDEX idx_user_id (user_id)
);

-- Comment likes table
CREATE TABLE comment_likes (
    id VARCHAR(255) PRIMARY KEY,
    comment_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_comment_like (comment_id, user_id),
    INDEX idx_user_id (user_id)
);

-- Auth tokens table
CREATE TABLE auth_tokens (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    access_token VARCHAR(500) NOT NULL,
    refresh_token VARCHAR(500) NOT NULL,
    oauth_id VARCHAR(255),
    expires_in INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_access_token (access_token),
    INDEX idx_refresh_token (refresh_token)
);

-- Categories table
CREATE TABLE categories (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_category BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## Response Format Chuẩn

Tất cả API responses nên follow format này:

```json
{
  "code": 200,
  "data": { ... },
  "message": "Success",
  "paging": {
    "cursor": "string",
    "next_cursor": "string",
    "limit": 20,
    "total": 100,
    "page": 1,
    "has_next": true
  }
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if true; // Public read
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Comments collection
    match /comments/{commentId} {
      allow read: if true; // Public read
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Post likes collection
    match /post_likes/{likeId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Comment likes collection
    match /comment_likes/{likeId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false; // Only admin can write
    }
    
    // Auth tokens collection
    match /auth_tokens/{tokenId} {
      allow read: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
      allow write: if request.auth != null && 
        request.resource.data.user_id == request.auth.uid;
    }
  }
}
```

---

