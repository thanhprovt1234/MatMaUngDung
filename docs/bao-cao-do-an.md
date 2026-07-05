# THIẾT KẾ VÀ TRIỂN KHAI PROTOTYPE BẢO MẬT CHO NỀN TẢNG THƯƠNG MẠI ĐIỆN TỬ

**Môn học:** NT219 - Cryptography  
**Đề tài:** Thiết kế và đánh giá an toàn mật mã cho nền tảng thương mại điện tử  
**Prototype:** UTEShop - Online Shopping Service Platform  
**Sinh viên thực hiện:** Nguyễn Xuân Thành  
**Công nghệ chính:** Java Servlet/JSP, Maven, Jetty, Apache HTTP Server, MySQL, Google OIDC, JWT, AES-GCM, ZeroSSL

---

## Tóm Tắt

Thương mại điện tử là một trong những loại hệ thống web thường xuyên xử lý dữ liệu nhạy cảm như thông tin tài khoản, địa chỉ giao hàng, số điện thoại, giỏ hàng, đơn hàng và dữ liệu thanh toán. Nếu không được thiết kế đúng, hệ thống có thể gặp các rủi ro như nghe lén lưu lượng, đánh cắp phiên đăng nhập, lưu trữ dữ liệu thẻ sai cách, rò rỉ dữ liệu cá nhân trong cơ sở dữ liệu hoặc lạm dụng API.

Báo cáo này trình bày quá trình thiết kế và triển khai một prototype nền tảng thương mại điện tử có tên UTEShop với trọng tâm là ứng dụng các cơ chế mật mã và bảo mật web trong các luồng nghiệp vụ quan trọng. Hệ thống được triển khai với Apache reverse proxy, TLS sử dụng chứng chỉ ZeroSSL, xác thực Google OpenID Connect theo Authorization Code Flow kết hợp PKCE, quản lý phiên bằng JWT cookie an toàn, mã hóa dữ liệu nhạy cảm cấp trường bằng AES-256-GCM, và mô phỏng luồng thanh toán tokenization theo định hướng PCI DSS, trong đó hệ thống không lưu PAN hoặc CVV.

Kết quả thực nghiệm cho thấy hệ thống có thể thực hiện luồng mua hàng từ thêm sản phẩm vào giỏ, checkout, nhập thông tin thẻ thử nghiệm, tạo payment token, tạo đơn hàng và lưu dữ liệu nhạy cảm ở dạng mã hóa. Trong cơ sở dữ liệu, thông tin địa chỉ và số điện thoại được lưu ở dạng `ENC:v1:...`, trong khi thông tin thanh toán chỉ lưu token, loại thẻ và bốn số cuối. Điều này giúp giảm rủi ro khi cơ sở dữ liệu bị lộ và thể hiện được các nguyên tắc cốt lõi của bảo mật thương mại điện tử.

---

## Chương 1. Mở Đầu

### 1.1. Lý Do Chọn Đề Tài

Các nền tảng mua sắm trực tuyến như Shopee, Amazon hoặc các hệ thống thương mại điện tử nội bộ đều phải xử lý nhiều loại dữ liệu có giá trị cao. Trong một phiên giao dịch thông thường, người dùng có thể đăng nhập, lưu địa chỉ, thêm sản phẩm vào giỏ hàng, đặt đơn và thực hiện thanh toán. Mỗi bước đều có thể trở thành mục tiêu tấn công.

Một số rủi ro phổ biến gồm:

- Kẻ tấn công nghe lén dữ liệu nếu website không sử dụng HTTPS đúng cách.
- Token phiên bị đánh cắp qua XSS hoặc cookie không được bảo vệ.
- Dữ liệu cá nhân như địa chỉ, số điện thoại bị lộ khi database bị truy cập trái phép.
- Hệ thống lưu số thẻ đầy đủ hoặc CVV, làm tăng rủi ro vi phạm PCI DSS.
- API đăng nhập hoặc OTP bị brute force nếu không có rate limiting.
- Khóa mã hóa bị hard-code trong source code hoặc commit lên GitHub.

Vì vậy, đề tài tập trung vào việc xây dựng một prototype có thể minh họa các kỹ thuật bảo mật quan trọng trong hệ thống thương mại điện tử, đặc biệt là những kỹ thuật liên quan đến mật mã ứng dụng.

### 1.2. Mục Tiêu Đề Tài

Mục tiêu chính của đề tài là xây dựng và đánh giá một prototype thương mại điện tử với các cơ chế bảo mật sau:

- Thiết lập HTTPS/TLS với chứng chỉ được cấp bởi CA thay vì chứng chỉ tự ký.
- Triển khai đăng nhập Google SSO bằng OAuth2/OpenID Connect Authorization Code Flow kết hợp PKCE.
- Quản lý phiên bằng JWT cookie với các thuộc tính bảo mật như `HttpOnly`, `Secure`, `SameSite=Lax`.
- Mã hóa dữ liệu nhạy cảm trong database bằng AES-256-GCM ở cấp trường.
- Mô phỏng tokenization trong thanh toán, không lưu PAN và CVV.
- Phân tích trade-off về hiệu năng, chi phí và security posture.

### 1.3. Phạm Vi Đề Tài

Đề tài được triển khai dưới dạng prototype phục vụ học thuật. Hệ thống không xử lý thẻ thanh toán thật, không tích hợp payment gateway thật như Stripe hoặc Braintree, và không triển khai đầy đủ Kubernetes, Vault, HSM hoặc Cloud KMS. Các thành phần này được phân tích dưới góc nhìn thiết kế và hướng phát triển.

Phạm vi triển khai thực tế gồm:

- Java Web Application chạy bằng Jetty.
- Apache HTTP Server đóng vai trò reverse proxy và TLS termination.
- MySQL lưu trữ dữ liệu người dùng, giỏ hàng, đơn hàng và giao dịch thanh toán.
- Google OAuth Client dùng cho OIDC SSO.
- AES-GCM dùng cho field-level encryption.
- Mock payment gateway để mô phỏng tokenization.

---

## Chương 2. Cơ Sở Lý Thuyết

### 2.1. TLS/HTTPS Và Chứng Chỉ Số

TLS là giao thức bảo vệ kênh truyền giữa browser và server. Khi website sử dụng HTTPS, dữ liệu được mã hóa trong quá trình truyền, giúp chống nghe lén và sửa đổi nội dung trên đường truyền. TLS đồng thời cho phép browser xác thực server thông qua chứng chỉ số được cấp bởi Certificate Authority.

Trong prototype, domain `uteshop.kesug.com` được cấu hình thông qua Apache HTTPS với chứng chỉ ZeroSSL. Apache đóng vai trò điểm kết thúc TLS, sau đó reverse proxy request về ứng dụng Java chạy nội bộ ở `http://127.0.0.1:8081`.

Mô hình triển khai:

```text
Browser
   |
   | HTTPS + ZeroSSL certificate
   v
Apache HTTP Server
   |
   | HTTP local reverse proxy
   v
Jetty Java Web App
   |
   v
MySQL
```

### 2.2. OAuth2, OpenID Connect Và Authorization Code Flow + PKCE

OAuth2 là framework ủy quyền, cho phép ứng dụng truy cập tài nguyên thay mặt người dùng mà không cần biết mật khẩu của người dùng. OpenID Connect là lớp định danh xây trên OAuth2, cho phép ứng dụng xác thực người dùng thông qua `ID Token`.

Authorization Code Flow là luồng chuẩn cho web server. Thay vì trả token trực tiếp về browser, Google trả về một `authorization code`. Server sau đó dùng code này, kèm client secret và PKCE code verifier, để đổi lấy token tại token endpoint.

PKCE bổ sung hai giá trị:

- `code_verifier`: chuỗi bí mật tạm thời do app tạo.
- `code_challenge`: giá trị hash từ `code_verifier` gửi lên Google ở bước đầu.

Nhờ đó, nếu authorization code bị chặn trên đường redirect, attacker vẫn không thể đổi code lấy token nếu không có `code_verifier`.

### 2.3. JWT Và Cookie Bảo Mật

JWT là token có cấu trúc gồm header, payload và signature. Trong hệ thống, JWT được dùng để biểu diễn phiên đăng nhập nội bộ sau khi người dùng đăng nhập thường hoặc đăng nhập bằng Google.

JWT được lưu trong cookie với các thuộc tính:

- `HttpOnly`: JavaScript phía browser không đọc được token qua `document.cookie`.
- `Secure`: cookie chỉ được gửi qua HTTPS.
- `SameSite=Lax`: giảm rủi ro CSRF trong nhiều tình huống cross-site phổ biến.

Các thuộc tính này không thay thế hoàn toàn việc chống XSS/CSRF, nhưng giúp giảm đáng kể rủi ro đánh cắp token phiên.

### 2.4. AES-GCM Và Field-Level Encryption

AES là thuật toán mã hóa đối xứng phổ biến. GCM là chế độ hoạt động cung cấp cả tính bí mật và tính toàn vẹn. Khi dùng AES-GCM, dữ liệu bị thay đổi hoặc ciphertext bị sửa sẽ không giải mã hợp lệ do tag xác thực không khớp.

Trong hệ thống, AES-256-GCM được dùng để mã hóa một số trường nhạy cảm trước khi lưu database:

- `User.address`
- `Order.address`
- `Order.phone`

Dữ liệu mã hóa có định dạng:

```text
ENC:v1:<base64_iv>:<base64_ciphertext_and_tag>
```

Khóa AES được nạp từ biến môi trường `FIELD_ENCRYPTION_KEY`, không hard-code trong source code. Đây là hướng tiếp cận phù hợp với prototype. Trong production, khóa này nên được quản lý bởi Vault hoặc Cloud KMS.

### 2.5. Payment Tokenization Và PCI DSS

PAN là số thẻ thanh toán đầy đủ. CVV là mã bảo mật của thẻ. Theo tinh thần PCI DSS, hệ thống thương mại điện tử nên hạn chế tối đa việc lưu trữ dữ liệu thẻ, đặc biệt không lưu CVV sau authorization.

Tokenization là kỹ thuật thay thế dữ liệu thẻ nhạy cảm bằng một token đại diện. Token này có thể được lưu trong hệ thống để tham chiếu giao dịch, trong khi PAN/CVV không được lưu trong database của merchant.

Trong prototype, hệ thống mô phỏng payment gateway:

- Nhận số thẻ test.
- Kiểm tra định dạng và Luhn.
- Xác định brand thẻ, ví dụ VISA.
- Sinh token dạng `pay_tok_...`.
- Chỉ lưu token, brand và bốn số cuối.
- Không lưu PAN đầy đủ và CVV.

---

## Chương 3. Ngữ Cảnh Hệ Thống, Rủi Ro Và Mục Tiêu Bảo Mật

### 3.1. Ngữ Cảnh Nghiệp Vụ Và Phạm Vi Bảo Vệ

UTEShop được đặt trong ngữ cảnh một nền tảng thương mại điện tử cho phép người dùng đăng nhập, xem sản phẩm, thêm hàng vào giỏ, đặt hàng và thực hiện thanh toán thử nghiệm. Hệ thống có ba nhóm chủ thể chính: khách hàng sử dụng trình duyệt, quản trị viên vận hành dữ liệu sản phẩm và đơn hàng, cùng các hệ thống bên ngoài như Google Identity Provider và mock payment gateway. Vì đây là prototype học thuật, hệ thống không xử lý thẻ thật và không khẳng định đạt chứng nhận PCI DSS đầy đủ; mục tiêu là mô phỏng đúng các nguyên tắc bảo vệ dữ liệu quan trọng trong một luồng thương mại điện tử.

Phạm vi bảo vệ của báo cáo tập trung vào các điểm tiếp xúc có rủi ro cao: kênh truyền giữa browser và server, phiên đăng nhập, dữ liệu cá nhân lưu trong database, dữ liệu thẻ xuất hiện trong bước checkout và các secret dùng để kết nối hoặc mã hóa. Những thành phần nằm ngoài phạm vi prototype như hạ tầng cloud production, hệ thống chống gian lận bằng machine learning, HSM hoặc payment gateway thật được trình bày như hướng phát triển.

### 3.2. Trust Boundary Và Giả Định An Toàn

Trong mô hình bảo mật của hệ thống, browser và mạng Internet được xem là vùng không tin cậy hoàn toàn. Người dùng có thể bị lừa truy cập trang độc hại, request có thể đi qua môi trường mạng công cộng và dữ liệu nhập từ form có thể chứa giá trị không hợp lệ. Apache là điểm nhận request từ Internet và là nơi kết thúc TLS. Jetty chạy ứng dụng Java trong vùng nội bộ, MySQL là kho dữ liệu cần được bảo vệ, còn Google được xem là Identity Provider tin cậy trong phạm vi xác thực OIDC.

```text
Untrusted Zone: Browser + Internet
Trust Boundary: HTTPS/TLS at Apache
Internal Zone: Jetty Java App + MySQL
External Trusted Provider: Google OIDC
External Simulated Provider: Mock Payment Gateway
```

### 3.3. Tài Sản Cần Bảo Vệ

Các tài sản quan trọng của hệ thống gồm tài khoản người dùng, quyền admin, JWT token, email, địa chỉ, số điện thoại, giỏ hàng, đơn hàng, trạng thái thanh toán, dữ liệu thẻ nhập tạm thời trong quá trình checkout, khóa mã hóa `FIELD_ENCRYPTION_KEY`, Google OAuth client secret và thông tin kết nối database. Trong đó, JWT token ảnh hưởng trực tiếp đến quyền truy cập phiên; địa chỉ và số điện thoại là dữ liệu cá nhân; còn PAN và CVV là dữ liệu thanh toán nhạy cảm không nên lưu trong database của ứng dụng.

### 3.4. Mô Hình Rủi Ro

Rủi ro được xác định dựa trên các luồng nghiệp vụ chính thay vì chỉ liệt kê theo công nghệ. Khi người dùng đăng nhập, nguy cơ chính là đánh cắp phiên hoặc brute force. Khi người dùng checkout, nguy cơ chuyển sang lộ dữ liệu cá nhân và dữ liệu thẻ. Khi dữ liệu được lưu trong MySQL, nguy cơ quan trọng là lộ plaintext nếu database bị truy cập trái phép. Bảng dưới đây mô tả mối liên hệ giữa rủi ro, tác động và cơ chế giảm thiểu trong prototype.

| Rủi ro | Tác động | Cơ chế giảm thiểu trong prototype |
|---|---|---|
| Nghe lén hoặc sửa đổi traffic | Lộ cookie, dữ liệu đăng nhập và dữ liệu checkout | HTTPS với chứng chỉ ZeroSSL tại Apache |
| Đánh cắp JWT qua script độc hại | Chiếm phiên đăng nhập của người dùng | Cookie `HttpOnly`, `Secure` và `SameSite=Lax` |
| Lộ cơ sở dữ liệu | Lộ địa chỉ, số điện thoại và thông tin đơn hàng | Mã hóa address và phone bằng AES-256-GCM |
| Lưu PAN hoặc CVV | Tăng phạm vi rủi ro PCI DSS và hậu quả khi DB bị lộ | Tokenization, chỉ lưu last4, brand và payment token |
| Brute force login/OTP | Chiếm tài khoản hoặc spam luồng xác thực | Rate limiting, OTP và lockout cơ bản |
| Lộ khóa mã hóa hoặc secret | Có thể giải mã dữ liệu hoặc giả mạo tích hợp | Secret lấy từ biến môi trường, định hướng Vault/KMS |

### 3.5. Mục Tiêu Bảo Mật

Từ ngữ cảnh và rủi ro trên, hệ thống đặt ra các mục tiêu bảo mật cụ thể. Các mục tiêu này đóng vai trò cầu nối giữa yêu cầu nghiệp vụ và kiến trúc giải pháp, giúp tránh nhầm lẫn giữa việc triển khai công cụ với việc giải quyết rủi ro.

| Mục tiêu bảo mật | Ý nghĩa | Cơ chế triển khai |
|---|---|---|
| Bảo vệ kênh truyền | Dữ liệu giữa browser và server không bị đọc hoặc sửa dễ dàng trên mạng | TLS/HTTPS với chứng chỉ ZeroSSL |
| Xác thực người dùng an toàn | Giảm rủi ro tự quản lý mật khẩu và hỗ trợ SSO | Google OIDC Authorization Code Flow + PKCE |
| Bảo vệ phiên đăng nhập | Giảm khả năng token bị đọc bởi script phía client | JWT cookie `HttpOnly`, `Secure`, `SameSite=Lax` |
| Bảo vệ dữ liệu lưu trữ | Database bị lộ không làm lộ ngay địa chỉ và số điện thoại plaintext | AES-256-GCM field-level encryption |
| Giảm rủi ro dữ liệu thẻ | Ứng dụng không lưu PAN/CVV sau authorization | Mock payment tokenization |
| Giảm lạm dụng API xác thực | Hạn chế brute force và spam OTP | Rate limiting và lockout cơ bản |

---

## Chương 4. Kiến Trúc Giải Pháp Và Kịch Bản Triển Khai

### 4.1. Kiến Trúc Logic Của Giải Pháp

Kiến trúc logic mô tả các khối chức năng và quan hệ bảo mật giữa chúng, không phụ thuộc vào việc hệ thống đang chạy trên máy local hay server thật. Ở mức logic, browser chỉ là client gửi request; UTEShop App chịu trách nhiệm xử lý nghiệp vụ, tạo phiên, mã hóa dữ liệu và điều phối checkout; Google OIDC chịu trách nhiệm xác thực danh tính; mock payment gateway mô phỏng bước tokenization; MySQL lưu dữ liệu người dùng, giỏ hàng, đơn hàng và giao dịch thanh toán đã được giảm thiểu dữ liệu nhạy cảm.

```text
Browser Client
  -> UTEShop Web App
      -> Google OIDC for identity verification
      -> Mock Payment Gateway for tokenization
      -> MySQL for users, carts, orders, payment tokens
```

| Khối logic | Vai trò | Cơ chế bảo mật liên quan |
|---|---|---|
| Browser Client | Hiển thị giao diện và gửi request | Nhận cookie `HttpOnly`/`Secure`, giao tiếp qua HTTPS |
| UTEShop App | Xử lý authentication, cart, order và payment | Verify OIDC, ký JWT, gọi AES-GCM, tokenization |
| Google OIDC | Xác thực danh tính người dùng | Authorization Code Flow + PKCE, ID Token verification |
| Mock Payment Gateway | Mô phỏng xử lý thẻ và sinh token | Không trả PAN/CVV về database |
| MySQL | Lưu dữ liệu ứng dụng | Lưu ciphertext và payment token thay vì plaintext/PAN |

### 4.2. Kiến Trúc Network Và Host

Kiến trúc network/host mô tả cách các thành phần được đặt trên môi trường chạy thực tế. Trong prototype, Apache HTTP Server là host-facing component nhận request từ browser qua domain `uteshop.kesug.com`. Apache kết thúc TLS bằng chứng chỉ ZeroSSL, sau đó reverse proxy request về Jetty chạy ở cổng nội bộ `8081`. MySQL được sử dụng làm database phía sau ứng dụng. Cách tách này giúp phân biệt rõ server công khai nhận HTTPS với app server nội bộ xử lý logic.

```text
Internet Browser
  -- HTTPS :443, ZeroSSL --> Apache HTTP Server
  -- HTTP localhost:8081 --> Jetty Maven Plugin / UTEShop
  -- JDBC localhost:3306 --> MySQL
```

### 4.3. Kịch Bản Triển Khai

Kịch bản triển khai là cách hiện thực hóa kiến trúc trong môi trường demo, không phải bản thân kiến trúc bảo mật. Trong kịch bản hiện tại, domain `uteshop.kesug.com` được trỏ về máy chạy Apache. Apache được cấu hình virtual host HTTPS, nạp certificate ZeroSSL và reverse proxy về ứng dụng Java ở `http://127.0.0.1:8081/uteshop`. Jetty Maven Plugin chạy ứng dụng Java Servlet/JSP, còn MySQL lưu dữ liệu nghiệp vụ. Khi báo cáo kết quả, cần trình bày rõ đây là môi trường triển khai prototype, không nhầm với kiến trúc logic của giải pháp.

### 4.4. Data Flow Đăng Nhập Google OIDC

Luồng đăng nhập Google bắt đầu khi người dùng bấm đăng nhập bằng Google. UTEShop tạo `state`, `nonce` và PKCE `code_verifier`, sau đó chuyển browser sang Google authorization endpoint. Sau khi Google xác thực người dùng, browser được redirect về callback của UTEShop cùng authorization code. Server kiểm tra `state`, dùng code và `code_verifier` để đổi token, verify ID Token bằng khóa công khai của Google, sau đó tạo session nội bộ và JWT cookie. Trong luồng này, mật khẩu Google không đi qua UTEShop, còn authorization code không đủ giá trị nếu thiếu `code_verifier`.

```text
User -> UTEShop: Login with Google
UTEShop -> Google: authorization request + code_challenge
Google -> UTEShop callback: authorization_code
UTEShop -> Google: code + code_verifier
Google -> UTEShop: ID Token
UTEShop -> Browser: internal JWT cookie
```

### 4.5. Data Flow Checkout Và Tokenization

Luồng checkout tập trung vào nguyên tắc không lưu dữ liệu thẻ nhạy cảm. Người dùng nhập địa chỉ, số điện thoại và thông tin thẻ test trên form đặt hàng. Ứng dụng kiểm tra dữ liệu thẻ trong bộ nhớ, mô phỏng gateway để sinh payment token và chỉ lưu token, brand, bốn số cuối cùng trạng thái giao dịch. PAN đầy đủ và CVV không được lưu vào database. Sau khi payment mock được approve, hệ thống tạo order; địa chỉ và số điện thoại của order được mã hóa trước khi ghi xuống MySQL.

```text
Checkout Form
  -> Validate card in app memory
  -> Generate pay_tok_xxx
  -> Store paymentToken + cardLast4 + cardBrand
  -> Encrypt order.address and order.phone
  -> Save order and payment transaction
```

### 4.6. Triển Khai Các Cơ Chế Bảo Mật Trong Ứng Dụng

Ở tầng ứng dụng, `GoogleOAuthStartController` và `GoogleOAuthCallbackController` xử lý OIDC. `JwtUtils` tạo và kiểm tra JWT cookie. `FieldEncryptionUtils` thực hiện AES-GCM, còn `EncryptedStringConverter` giúp JPA tự động mã hóa hoặc giải mã các trường nhạy cảm. `PaymentTokenUtils` và `PaymentServiceImpl` mô phỏng tokenization. Các thành phần này là phần hiện thực của kiến trúc bảo mật đã nêu ở trên, tức là chúng phục vụ các mục tiêu bảo mật cụ thể thay vì chỉ là các chức năng độc lập.

---

## Chương 5. Thực Nghiệm Và Kết Quả

### 5.1. Môi Trường Thử Nghiệm

| Thành phần | Công nghệ |
|---|---|
| Hệ điều hành | Windows |
| Web server | Apache HTTP Server |
| App server | Jetty Maven Plugin |
| Backend | Java Servlet/JSP |
| ORM | JPA/Hibernate |
| Database | MySQL |
| TLS certificate | ZeroSSL |
| Identity Provider | Google OIDC |
| Encryption | AES-256-GCM |
| Payment | Mock tokenization |

### 5.2. Kiểm Thử HTTPS

Mục tiêu kiểm thử:

- Browser truy cập domain qua HTTPS.
- Certificate được cấp bởi ZeroSSL.
- Không dùng chứng chỉ tự ký trong môi trường demo domain.

Kết quả mong đợi:

```text
Issued To: uteshop.kesug.com
Issued By: ZeroSSL ECC DV SSL CA 2
```

Minh chứng đề xuất: chụp màn hình Certificate Viewer của browser.

### 5.3. Kiểm Thử Google OIDC

Mục tiêu:

- User có thể đăng nhập bằng tài khoản Google.
- Server nhận authorization code và verify ID token.
- Sau đăng nhập, hệ thống tạo session/JWT nội bộ.

Kết quả:

- Đăng nhập Google thành công.
- User được tạo hoặc tìm trong bảng `user`.
- Session có `account` và `userId`.

Minh chứng đề xuất:

- Ảnh màn hình nút đăng nhập Google.
- Ảnh sau khi login thành công.
- Ảnh Google OAuth client cấu hình redirect URI.

### 5.4. Kiểm Thử Cart Và Checkout

Quy trình:

1. Tạo dữ liệu mẫu: store, category, product, delivery.
2. Đăng nhập user.
3. Bấm `Add to cart`.
4. Kiểm tra bảng `cart` và `cart_item`.

Câu SQL kiểm chứng:

```sql
SELECT
    c._id AS cart_id,
    c.user_id,
    ci.product_id,
    p.name AS product_name,
    ci.count
FROM `cart` c
JOIN `cart_item` ci ON ci.cart_id = c._id
JOIN `product` p ON p._id = ci.product_id
WHERE c.user_id = 1;
```

Kết quả thực nghiệm:

```text
cart_id = 1
user_id = 1
product_id = 1
product_name = Test Product
count = 4
```

Kết quả này chứng minh sản phẩm đã được lưu vào giỏ hàng trong database.

### 5.5. Kiểm Thử Payment Tokenization

Thông tin thẻ test:

```text
Card number: 4111111111111111
Expiry: 12/30
CVV: 123
```

Sau khi bấm Place Order, kiểm tra bảng `payment_transaction`:

```sql
SELECT
    `_id`,
    `paymentToken`,
    `cardLast4`,
    `cardBrand`,
    `amount`,
    `status`,
    `gatewayReference`,
    `gatewayResponseCode`,
    `panRetained`,
    `cvvRetained`,
    `createdAt`
FROM `payment_transaction`
ORDER BY `_id` DESC;
```

Kết quả:

```text
paymentToken = pay_tok_...
cardLast4 = 1111
cardBrand = VISA
amount = 56
status = AUTHORIZED
gatewayResponseCode = MOCK_APPROVED
panRetained = 0
cvvRetained = 0
```

Đánh giá:

- Hệ thống đã tạo payment token thành công.
- Không lưu PAN đầy đủ.
- Không lưu CVV.
- Chỉ lưu bốn số cuối và brand để phục vụ hiển thị/đối soát.

### 5.6. Kiểm Thử Order Và Field-Level Encryption

Kiểm tra bảng `orders`:

```sql
SELECT
    `_id`,
    `user_id`,
    `store_id`,
    `delivery_id`,
    `address`,
    `phone`,
    `status`,
    `isPaidBefore`
FROM `orders`
ORDER BY `_id` DESC;
```

Kết quả:

```text
status = PROCESSED
isPaidBefore = 1
address = ENC:v1:...
phone = ENC:v1:...
```

Đánh giá:

- Order đã được tạo.
- Payment đã được xử lý.
- Địa chỉ và số điện thoại không lưu plaintext trong DB.
- AES-GCM field-level encryption hoạt động đúng.

---

## Chương 6. Đánh Giá Theo Yêu Cầu Đề Bài

### 6.1. Mapping Với Learning Objectives

| Yêu cầu | Mức độ đáp ứng trong prototype |
|---|---|
| OAuth2 Authorization Code + PKCE, OIDC, JWT | Đã triển khai Google OIDC Authorization Code + PKCE và JWT cookie |
| Payment tokenization, PCI DSS constraints, no PAN retention | Đã mô phỏng tokenization, không lưu PAN/CVV |
| KMS/HSM, envelope encryption, TDE vs field-level encryption, Vault | Đã triển khai field-level encryption AES-GCM và secrets qua env; chưa có KMS/HSM/Vault thật |
| Rate limiting, signed requests, HMAC, mTLS, fraud detection | Đã có rate limiting/OTP/lockout ở login; chưa có HMAC/mTLS/fraud ML |
| Latency/throughput, cost estimation, security posture | Đã phân tích định tính; có thể bổ sung đo request bằng DevTools/PowerShell |

### 6.2. Đánh Giá PCI DSS Ở Mức Prototype

Prototype không nhằm chứng nhận PCI DSS đầy đủ. Tuy nhiên, hệ thống đã minh họa một số nguyên tắc quan trọng:

| Nguyên tắc | Cách đáp ứng |
|---|---|
| Không lưu Sensitive Authentication Data sau authorization | Không lưu CVV, `cvvRetained = 0` |
| Giảm phạm vi lưu trữ cardholder data | Không lưu PAN đầy đủ |
| Tokenization | Lưu `paymentToken = pay_tok_...` |
| Chỉ lưu thông tin tối thiểu | Lưu `cardLast4` và `cardBrand` |
| Bảo vệ dữ liệu nhạy cảm khác | Mã hóa address/phone bằng AES-GCM |

### 6.3. Đánh Giá Security Posture

| Rủi ro | Cơ chế đã triển khai | Hạn chế còn lại |
|---|---|---|
| Nghe lén traffic | HTTPS với ZeroSSL | Cần HSTS và cấu hình cipher suite production |
| Đánh cắp JWT qua JavaScript | Cookie `HttpOnly` | Cần CSP và sanitize input để chống XSS |
| CSRF | `SameSite=Lax` | Nên thêm CSRF token cho form nhạy cảm |
| Lộ database | AES-GCM field encryption | Nếu lộ key env vẫn có thể giải mã |
| Lộ PAN/CVV | Không lưu PAN/CVV, dùng token | Chưa tích hợp PSP thật |
| Brute force login | Rate limiting, OTP, lockout | Chưa có CAPTCHA/device fingerprint |
| Replay payment | Có order state cơ bản | Nên thêm idempotency key |
| Lộ secret | Secret lấy từ env, không hard-code | Nên dùng Vault/KMS production |

### 6.4. Phân Tích Latency Và Trade-Off

Các cơ chế bảo mật đều có chi phí nhất định:

- TLS làm tăng chi phí handshake ban đầu, nhưng browser có thể tái sử dụng connection.
- Google OIDC chậm hơn login thường vì có redirect và verify ID token, nhưng giảm rủi ro tự quản lý mật khẩu.
- AES-GCM có thêm chi phí mã hóa/giải mã, nhưng chỉ áp dụng cho field nhạy cảm nên overhead thấp hơn mã hóa toàn bộ database ở tầng ứng dụng.
- Tokenization thêm bước validate và sinh token, nhưng giảm đáng kể rủi ro khi database bị lộ.

Bảng đánh giá định tính:

| Chức năng | Cơ chế bảo mật | Trade-off |
|---|---|---|
| Truy cập web | HTTPS | Tăng handshake latency, đổi lại bảo mật kênh truyền |
| Login Google | OIDC + PKCE | Tăng redirect latency, đổi lại bảo mật xác thực tốt hơn |
| Lưu order | AES-GCM | Tăng nhẹ CPU, đổi lại bảo vệ PII trong DB |
| Thanh toán | Tokenization | Tăng xử lý nghiệp vụ, đổi lại không lưu PAN/CVV |

### 6.5. Ước Lượng Chi Phí Triển Khai

| Thành phần | Prototype hiện tại | Production đề xuất |
|---|---|---|
| TLS certificate | ZeroSSL | Managed certificate hoặc CA thương mại |
| Key management | Environment variable | Vault hoặc Cloud KMS |
| HSM | Chưa dùng | Dùng cho payment/signing key quan trọng |
| Payment | Mock gateway | Stripe/Braintree/PSP sandbox và production |
| Database encryption | Field-level AES-GCM | Field-level encryption + TDE + encrypted backup |
| Monitoring | Chưa đầy đủ | Prometheus/Grafana/ELK/Sentry |

Phân tích:

Trong prototype, chi phí gần như bằng 0 vì sử dụng công cụ local và certificate miễn phí. Nếu triển khai production với Cloud KMS, chi phí sẽ phụ thuộc số lần gọi encrypt/decrypt hoặc unwrap key. Để giảm chi phí, nên áp dụng envelope encryption: KMS bảo vệ master key, còn data key dùng để mã hóa dữ liệu và được cache ngắn hạn trong bộ nhớ an toàn.

---

## Chương 7. Hạn Chế Và Hướng Phát Triển

### 7.1. Hạn Chế

Prototype hiện tại có một số hạn chế:

- Chưa triển khai microservices đúng nghĩa như catalog service, cart service, order service, payment service riêng biệt.
- Chưa triển khai Kubernetes, API Gateway, Envoy/Kong.
- Chưa dùng Vault, Cloud KMS hoặc HSM thật.
- Payment gateway là mock, chưa tích hợp Stripe/Braintree sandbox.
- Chưa có mTLS hoặc HMAC signed request cho service-to-service.
- Chưa có fraud scoring hoặc behavioural analytics.
- Chưa thực hiện benchmark p95/p99 latency.
- Một số dữ liệu demo được tạo thủ công trong MySQL.

### 7.2. Hướng Phát Triển

Các hướng phát triển phù hợp:

- Tách hệ thống thành microservices: catalog, cart, order, payment.
- Thêm API Gateway để validate JWT, rate limit và log request.
- Tích hợp HashiCorp Vault hoặc Cloud KMS cho key management.
- Áp dụng envelope encryption thay vì dùng trực tiếp một AES key từ environment variable.
- Thêm idempotency key cho payment request để chống double submit.
- Tích hợp Stripe hoặc Braintree sandbox.
- Thêm CSRF token cho các form thay đổi trạng thái.
- Thêm CSP header để giảm rủi ro XSS.
- Dùng OWASP ZAP để scan lỗ hổng web cơ bản.
- Tạo dashboard monitoring cho login failure, checkout failure và payment status.

---

## Chương 8. Kết Luận

Đề tài đã xây dựng được một prototype thương mại điện tử có tích hợp nhiều cơ chế bảo mật và mật mã quan trọng trong thực tế. Hệ thống sử dụng TLS với chứng chỉ ZeroSSL để bảo vệ kênh truyền giữa browser và server, sử dụng Google OpenID Connect Authorization Code Flow kết hợp PKCE để tăng cường bảo mật xác thực, quản lý phiên bằng JWT cookie với các thuộc tính `HttpOnly`, `Secure` và `SameSite=Lax`.

Ở tầng dữ liệu, hệ thống triển khai field-level encryption bằng AES-256-GCM cho các trường nhạy cảm như địa chỉ và số điện thoại. Kết quả kiểm thử cho thấy dữ liệu trong bảng `orders` được lưu dưới dạng `ENC:v1:...`, không còn là plaintext. Ở luồng thanh toán, hệ thống mô phỏng tokenization theo định hướng PCI DSS, chỉ lưu payment token, bốn số cuối và brand thẻ, đồng thời không lưu PAN hoặc CVV. Bảng `payment_transaction` thể hiện rõ `panRetained = 0` và `cvvRetained = 0`.

Mặc dù prototype chưa triển khai đầy đủ các thành phần production như KMS/HSM, Vault, microservices, mTLS hoặc fraud ML scoring, kết quả đạt được đã minh họa được các nguyên tắc cốt lõi trong thiết kế bảo mật cho nền tảng thương mại điện tử. Đây là nền tảng phù hợp để tiếp tục mở rộng thành kiến trúc production-like trong tương lai.

---

## Phụ Lục A. Các Câu SQL Kiểm Chứng

### A.1. Kiểm Tra Cart

```sql
SELECT
    c._id AS cart_id,
    c.user_id,
    ci.product_id,
    p.name AS product_name,
    ci.count
FROM `cart` c
JOIN `cart_item` ci ON ci.cart_id = c._id
JOIN `product` p ON p._id = ci.product_id
WHERE c.user_id = 1;
```

### A.2. Kiểm Tra Payment Tokenization

```sql
SELECT
    `_id`,
    `paymentToken`,
    `cardLast4`,
    `cardBrand`,
    `amount`,
    `status`,
    `gatewayReference`,
    `gatewayResponseCode`,
    `panRetained`,
    `cvvRetained`,
    `createdAt`
FROM `payment_transaction`
ORDER BY `_id` DESC;
```

### A.3. Kiểm Tra Order Và Field-Level Encryption

```sql
SELECT
    `_id`,
    `user_id`,
    `store_id`,
    `delivery_id`,
    `address`,
    `phone`,
    `status`,
    `isPaidBefore`
FROM `orders`
ORDER BY `_id` DESC;
```

### A.4. Tạo Delivery Mẫu

```sql
INSERT INTO `delivery`
(`_id`, `name`, `description`, `price`, `isDeleted`, `createdAt`, `updatedAt`)
VALUES
(1, 'Standard Shipping', 'Default shipping method for checkout test', 0, 0, NOW(), NOW());
```

---

## Phụ Lục B. Danh Sách Minh Chứng Nên Đưa Vào Báo Cáo

1. Ảnh chứng chỉ TLS ZeroSSL của `uteshop.kesug.com`.
2. Ảnh đăng nhập Google thành công.
3. Ảnh cookie JWT trong DevTools có `HttpOnly`, `Secure`, `SameSite`.
4. Ảnh trang home có sản phẩm thật và nút Add to cart.
5. Ảnh bảng `cart_item` có product trong cart.
6. Ảnh màn hình checkout nhập card test.
7. Ảnh bảng `payment_transaction` có `pay_tok_...`, `cardLast4`, `panRetained = 0`, `cvvRetained = 0`.
8. Ảnh bảng `orders` có `address` và `phone` dạng `ENC:v1:...`.
9. Ảnh code `FieldEncryptionUtils`.
10. Ảnh code Google OIDC callback hoặc cấu hình Google Cloud OAuth client.
