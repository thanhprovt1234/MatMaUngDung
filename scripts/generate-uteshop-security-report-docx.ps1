$ErrorActionPreference = "Stop"

$outputPath = "C:\Users\nguye\Downloads\Bao_cao_UTEShop_Security_Project_Code_Hinh.docx"
$architectureSvgPath = "C:\Users\nguye\AnToanWeb\docs\uteshop-architecture-detailed.svg"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

$wdFormatDocumentDefault = 16
$wdStory = 6
$wdPageBreak = 7
$wdAlignLeft = 0
$wdAlignCenter = 1
$wdAlignJustify = 3
$wdLineSpaceMultiple = 5

try {
    $doc = $word.Documents.Add()
    $selection = $word.Selection

    $doc.PageSetup.TopMargin = $word.CentimetersToPoints(2.5)
    $doc.PageSetup.BottomMargin = $word.CentimetersToPoints(2.5)
    $doc.PageSetup.LeftMargin = $word.CentimetersToPoints(3)
    $doc.PageSetup.RightMargin = $word.CentimetersToPoints(2)

    $doc.Styles.Item("Normal").Font.Name = "Times New Roman"
    $doc.Styles.Item("Normal").Font.Size = 13
    $doc.Styles.Item("Normal").ParagraphFormat.Alignment = $wdAlignJustify
    $doc.Styles.Item("Normal").ParagraphFormat.LineSpacingRule = $wdLineSpaceMultiple
    $doc.Styles.Item("Normal").ParagraphFormat.LineSpacing = 18
    $doc.Styles.Item("Normal").ParagraphFormat.SpaceAfter = 6

    function Set-Normal {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Size = 13
        $selection.Font.Bold = $false
        $selection.Font.Italic = $false
        $selection.ParagraphFormat.Alignment = $wdAlignJustify
        $selection.ParagraphFormat.FirstLineIndent = $word.CentimetersToPoints(1)
        $selection.ParagraphFormat.SpaceAfter = 6
    }

    function Add-Paragraph([string] $text) {
        Set-Normal
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-Centered([string] $text, [int] $size = 13, [bool] $bold = $false) {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Size = $size
        $selection.Font.Bold = $bold
        $selection.Font.Italic = $false
        $selection.ParagraphFormat.Alignment = $wdAlignCenter
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.ParagraphFormat.SpaceAfter = 6
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-Heading([string] $text, [int] $level = 1) {
        $styleName = "Heading $level"
        $selection.Style = $doc.Styles.Item($styleName)
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Bold = $true
        $selection.Font.Italic = $false
        if ($level -eq 1) {
            $selection.Font.Size = 16
            $selection.ParagraphFormat.Alignment = $wdAlignCenter
            $selection.ParagraphFormat.FirstLineIndent = 0
            $selection.ParagraphFormat.SpaceBefore = 12
            $selection.ParagraphFormat.SpaceAfter = 12
        } elseif ($level -eq 2) {
            $selection.Font.Size = 14
            $selection.ParagraphFormat.Alignment = $wdAlignLeft
            $selection.ParagraphFormat.FirstLineIndent = 0
            $selection.ParagraphFormat.SpaceBefore = 10
            $selection.ParagraphFormat.SpaceAfter = 6
        } else {
            $selection.Font.Size = 13
            $selection.ParagraphFormat.Alignment = $wdAlignLeft
            $selection.ParagraphFormat.FirstLineIndent = 0
            $selection.ParagraphFormat.SpaceBefore = 6
            $selection.ParagraphFormat.SpaceAfter = 3
        }
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-PageBreak {
        $selection.InsertBreak($wdPageBreak)
    }

    function Add-Code([string] $text) {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Consolas"
        $selection.Font.Size = 10
        $selection.Font.Bold = $false
        $selection.ParagraphFormat.Alignment = $wdAlignLeft
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-CodeBlock([string] $caption, [string] $text) {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Size = 12
        $selection.Font.Bold = $true
        $selection.ParagraphFormat.Alignment = $wdAlignLeft
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.TypeText($caption)
        $selection.TypeParagraph()

        $range = $selection.Range
        $table = $doc.Tables.Add($range, 1, 1)
        $table.Borders.Enable = $true
        $table.Shading.BackgroundPatternColor = 15921906
        $table.Range.Font.Name = "Consolas"
        $table.Range.Font.Size = 9
        $table.Cell(1, 1).Range.Text = $text
        $selection.SetRange($table.Range.End, $table.Range.End)
        $selection.TypeParagraph()
    }

    function Add-Caption([string] $text) {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Size = 12
        $selection.Font.Bold = $false
        $selection.Font.Italic = $true
        $selection.ParagraphFormat.Alignment = $wdAlignCenter
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-ImagePlaceholder([string] $caption) {
        $selection.Style = $doc.Styles.Item("Normal")
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Size = 12
        $selection.Font.Bold = $true
        $selection.ParagraphFormat.Alignment = $wdAlignCenter
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.TypeText("[CHEN ANH MINH CHUNG]")
        $selection.TypeParagraph()
        Add-Caption $caption
    }

    function Add-PictureIfExists([string] $path, [string] $caption, [double] $widthCm = 16.0) {
        if (Test-Path -LiteralPath $path) {
            $selection.ParagraphFormat.Alignment = $wdAlignCenter
            $selection.ParagraphFormat.FirstLineIndent = 0
            $shape = $selection.InlineShapes.AddPicture($path, $false, $true)
            $shape.LockAspectRatio = $true
            $shape.Width = $word.CentimetersToPoints($widthCm)
            $selection.TypeParagraph()
            Add-Caption $caption
        } else {
            Add-ImagePlaceholder $caption
        }
    }

    function Add-Table([string[]] $headers, [object[]] $rows) {
        $range = $selection.Range
        $table = $doc.Tables.Add($range, $rows.Count + 1, $headers.Count)
        $table.Borders.Enable = $true
        $table.Range.Font.Name = "Times New Roman"
        $table.Range.Font.Size = 12
        $table.Rows.Item(1).Range.Bold = $true
        $table.Rows.Item(1).Shading.BackgroundPatternColor = 14277081
        for ($c = 0; $c -lt $headers.Count; $c++) {
            $table.Cell(1, $c + 1).Range.Text = $headers[$c]
        }
        for ($r = 0; $r -lt $rows.Count; $r++) {
            for ($c = 0; $c -lt $headers.Count; $c++) {
                $table.Cell($r + 2, $c + 1).Range.Text = [string]$rows[$r][$c]
            }
        }
        $table.AutoFitBehavior(1) | Out-Null
        $selection.SetRange($table.Range.End, $table.Range.End)
        $selection.TypeParagraph()
    }

    Add-Centered "TRUONG DAI HOC CONG NGHE KY THUAT TP. HCM" 13 $true
    Add-Centered "KHOA CONG NGHE THONG TIN" 13 $true
    Add-Centered "----- o0o -----" 13 $false
    $selection.TypeParagraph()
    Add-Centered "DO AN KET THUC MON HOC" 16 $true
    Add-Centered "AN TOAN WEB VA UNG DUNG MAT MA" 14 $true
    $selection.TypeParagraph()
    Add-Centered "THIET KE VA TRIEN KHAI CAC CO CHE BAO MAT CHO NEN TANG THUONG MAI DIEN TU UTESHOP" 16 $true
    $selection.TypeParagraph()
    Add-Centered "Prototype: UTESHOP - Online Shopping Security Project" 13 $false
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    Add-Centered "Giang vien huong dan: ................................................" 13 $false
    Add-Centered "Sinh vien thuc hien: Nguyen Xuan Thanh" 13 $false
    Add-Centered "MSSV: ................................................" 13 $false
    Add-Centered "Lop: ................................................" 13 $false
    $selection.TypeParagraph()
    Add-Centered "Thanh pho Ho Chi Minh, thang 7 nam 2026" 13 $false
    Add-PageBreak

    Add-Heading "PHAN DANH GIA" 1
    Add-Paragraph "BO MON: AN TOAN THONG TIN / AN TOAN WEB"
    Add-Paragraph "TEN GVHD: ................................................"
    Add-Paragraph "DO AN: THIET KE VA TRIEN KHAI CAC CO CHE BAO MAT CHO NEN TANG THUONG MAI DIEN TU UTESHOP"
    Add-Heading "NHAN XET CUA GIANG VIEN" 2
    Add-Paragraph "................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................"
    Add-Paragraph "................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................"
    Add-Paragraph "Diem: ................................................"
    Add-Paragraph "Xac nhan cua giang vien: ................................................"
    Add-PageBreak

    Add-Heading "LOI CAM ON" 1
    Add-Paragraph "Truoc het, em xin gui loi cam on chan thanh den giang vien huong dan da dinh huong va ho tro em trong qua trinh thuc hien do an. Qua de tai nay, em co co hoi van dung kien thuc ve bao mat web, giao thuc xac thuc hien dai, ma hoa du lieu, quan ly bi mat va thanh toan an toan vao mot he thong thuong mai dien tu co luong nghiep vu gan voi thuc te."
    Add-Paragraph "Trong qua trinh trien khai, em da tim hieu va thuc hanh nhieu thanh phan quan trong nhu Apache HTTP Server, Jetty, Java Servlet/JSP, PostgreSQL/MySQL, Google OpenID Connect, JWT, CSRF token, Stripe Test Mode, HashiCorp Vault, Docker Compose, Envoy va Keycloak. Qua viec cau hinh, kiem thu va khac phuc loi, em hieu ro hon rang bao mat khong chi nam o thuat toan ma hoa, ma con phu thuoc vao cach thiet ke luong du lieu, cach quan ly khoa, cach luu tru thong tin nhay cam va cach giam pham vi tin cay cua tung thanh phan."
    Add-Paragraph "Em xin chan thanh cam on quy thay co da tao dieu kien de em co the thuc hien do an nay. Mac du da co gang hoan thien, bao cao va prototype khong tranh khoi thieu sot. Em mong nhan duoc nhan xet va gop y de tiep tuc cai thien he thong theo huong gan voi moi truong san xuat hon."
    Add-PageBreak

    Add-Heading "DANH MUC TU VIET TAT" 1
    Add-Table @("Tu viet tat", "Y nghia", "Giai thich trong de tai") @(
        @("TLS", "Transport Layer Security", "Bao ve kenh truyen Browser - Apache bang HTTPS"),
        @("OIDC", "OpenID Connect", "Giao thuc xac thuc danh tinh voi Google/Keycloak"),
        @("JWT", "JSON Web Token", "Token phien dang nhap noi bo cua ung dung"),
        @("PKCE", "Proof Key for Code Exchange", "Tang bao mat cho Authorization Code Flow"),
        @("CSRF", "Cross-Site Request Forgery", "Tan cong gui request trai phep tu site khac"),
        @("PSP", "Payment Service Provider", "Nha cung cap dich vu thanh toan, trong de tai la Stripe Sandbox"),
        @("PAN", "Primary Account Number", "So the day du, khong duoc luu trong DB ung dung"),
        @("CVV", "Card Verification Value", "Ma bao mat the, khong duoc luu sau authorization"),
        @("KMS", "Key Management Service", "Dich vu quan ly khoa; Vault Transit duoc dung de mo phong"),
        @("KV", "Key-Value", "Kho secret cua Vault"),
        @("Transit", "Vault Transit Secrets Engine", "API ma hoa/giai ma khong xuat key ra ung dung"),
        @("CSP", "Content Security Policy", "Header gioi han nguon script, frame, connect"),
        @("API Gateway", "Application Programming Interface Gateway", "Cong vao he thong, de tai dung Envoy trong stack production-like")
    )

    Add-Heading "DANH MUC BANG" 1
    Add-Table @("Bang", "Ten bang") @(
        @("Bang 1", "Tong hop cong nghe su dung trong UTESHOP"),
        @("Bang 2", "Tai san can bao ve va rui ro tuong ung"),
        @("Bang 3", "Mapping yeu cau bao mat voi co che trien khai"),
        @("Bang 4", "Bang chung thuc nghiem cho thanh toan Stripe"),
        @("Bang 5", "Bang chung thuc nghiem cho Vault KV va Vault Transit"),
        @("Bang 6", "Danh gia theo OWASP Top 10 lien quan den online shopping")
    )

    Add-Heading "DANH MUC HINH ANH" 1
    Add-Table @("Hinh", "Noi dung can chen") @(
        @("Hinh 1", "Kien truc Browser - Apache - Jetty - Database - External Services"),
        @("Hinh 2", "HTTPS domain uteshop.kesug.com tra ve header bao mat"),
        @("Hinh 3", "Luon dang nhap Google OIDC / Keycloak OIDC"),
        @("Hinh 4", "Luon thanh toan Stripe Test Mode"),
        @("Hinh 5", "Stripe Dashboard Sandbox va giao dich thanh cong"),
        @("Hinh 6", "Bang payment_transaction khong luu PAN/CVV"),
        @("Hinh 7", "Vault Agent render secrets.properties"),
        @("Hinh 8", "Du lieu phone/address trong DB duoc ma hoa dang vault:v..."),
        @("Hinh 9", "Docker Compose stack gom Envoy, Keycloak, Vault, PostgreSQL va UTESHOP Web"),
        @("Hinh 10", "Security audit log ghi login_failed, csrf_failed, payment_authorized")
    )
    Add-PageBreak

    Add-Heading "MUC LUC" 1
    $tocRange = $selection.Range
    $doc.TablesOfContents.Add($tocRange, $true, 1, 3) | Out-Null
    $selection.EndKey($wdStory) | Out-Null
    Add-PageBreak

    Add-Heading "CHUONG 1: GIOI THIEU" 1
    Add-Heading "1.1. Dat van de" 2
    Add-Paragraph "Thuong mai dien tu la mot loai he thong web xu ly dong thoi nhieu nhom du lieu nhay cam nhu tai khoan nguoi dung, thong tin lien he, dia chi giao hang, gio hang, don hang va du lieu thanh toan. Trong mot luong mua hang thong thuong, nguoi dung phai dang nhap, them san pham vao gio, nhap thong tin giao hang va thuc hien thanh toan. Moi buoc deu co the tro thanh diem tan cong neu he thong khong duoc thiet ke voi cac co che bao mat phu hop."
    Add-Paragraph "De tai UTESHOP duoc xay dung nham mo phong mot nen tang mua sam truc tuyen va trien khai cac co che bao mat quan trong trong moi truong prototype. Trong qua trinh phat trien, he thong duoc nang cap tu ung dung Java Web truyen thong len mot kien truc production-like hon, bao gom HTTPS qua Apache reverse proxy, Jetty noi bo, quan ly phien bang JWT, CSRF token, ghi log su kien bao mat, ma hoa du lieu nhay cam bang Vault Transit, quan ly secret qua Vault KV/Vault Agent, tich hop thanh toan Stripe Test Mode va scaffold Docker Compose voi Envoy, Keycloak, PostgreSQL, Vault va UTESHOP Web."
    Add-Heading "1.2. Muc tieu de tai" 2
    Add-Paragraph "Muc tieu cua de tai la thiet ke va trien khai mot prototype thuong mai dien tu co the chung minh cac co che bao mat hien dai trong cac luong nghiep vu cot loi. He thong can bao ve kenh truyen, bao ve phien dang nhap, khong luu tru du lieu the thanh toan nhay cam, ma hoa du lieu ca nhan trong database, quan ly secret tap trung va tao co so cho viec trien khai theo huong container/API Gateway/IdP."
    Add-Paragraph "Cac muc tieu ky thuat cu the bao gom: cau hinh HTTPS voi Apache va chung chi public CA, chan truy cap truc tiep vao Jetty, su dung Google OIDC, su dung BCrypt cho mat khau, OTP cho luong dang nhap, JWT cookie co HttpOnly/Secure/SameSite, CSRF token cho request thay doi trang thai, Stripe Test Mode cho thanh toan tokenization, Vault KV cho secret management, Vault Transit cho field-level encryption va Docker Compose cho production-like stack."
    Add-Heading "1.3. Doi tuong va pham vi nghien cuu" 2
    Add-Paragraph "Doi tuong nghien cuu cua de tai la cac co che bao mat ung dung web trong boi canh online shopping. Pham vi trien khai tap trung vao UTESHOP, mot ung dung Java Servlet/JSP chay tren Jetty, su dung JPA/Hibernate va database quan he. He thong hien tai co cac module san pham, gio hang, don hang, thanh toan, tai khoan nguoi dung va quan tri."
    Add-Paragraph "Do gioi han thoi gian va muc tieu hoc thuat, de tai chua tach thanh microservice hoan chinh. Thay vao do, de tai trien khai buoc nen la container platform gom Envoy, Keycloak, PostgreSQL, Vault va uteshop-web. Day la giai doan chuan bi truoc khi tach cac service Danh muc san pham, Gio hang, Don hang va Thanh toan thanh cac container rieng."
    Add-Heading "1.4. Phuong phap thuc hien" 2
    Add-Paragraph "De tai duoc thuc hien theo phuong phap vua phan tich rui ro vua trien khai thuc nghiem. Dau tien, cac rui ro chinh cua he thong online shopping duoc xac dinh dua tren luong nghiep vu. Tiep theo, moi rui ro duoc gan voi mot hoac nhieu co che giam thieu. Sau do, cac co che nay duoc cai dat truc tiep vao project, kiem thu bang trinh duyet, database, log va cong cu dong lenh."
    Add-Heading "1.5. Noi dung thuc hien" 2
    Add-Table @("Nhom cong viec", "Noi dung da thuc hien") @(
        @("Network security", "Apache HTTPS reverse proxy, HSTS, CSP, security headers, Jetty bind noi bo"),
        @("Authentication", "Dang nhap local bang BCrypt/OTP, Google OIDC, JWT cookie"),
        @("Application security", "CSRF filter, permission filter, security audit log, rate limiting login/OTP"),
        @("Secure storage", "Vault KV, Vault Agent, Vault Transit, field-level encryption cho phone/address"),
        @("Secure payment", "Stripe Test Mode, PaymentIntent, Card Element, khong luu PAN/CVV"),
        @("Production-like platform", "Dockerfile, Docker Compose, Envoy, Keycloak, PostgreSQL, Vault")
    )

    Add-Heading "CHUONG 2: CO SO LY THUYET" 1
    Add-Heading "2.1. Tong quan bao mat web trong thuong mai dien tu" 2
    Add-Paragraph "Mot he thong thuong mai dien tu co be mat tan cong rong hon cac website thong tin thong thuong vi no xu ly danh tinh nguoi dung, du lieu ca nhan, giao dich va thanh toan. Neu chi bao ve giao dien ma bo qua tang luu tru hoac luong thanh toan, he thong van co nguy co ro ri du lieu khi database bi truy cap trai phep. Vi vay, bao mat can duoc ap dung theo nhieu lop: kenh truyen, xac thuc, phan quyen, bao ve request, bao ve du lieu luu tru, bao ve secret va giam thieu du lieu thanh toan."
    Add-Heading "2.2. TLS, reverse proxy va security headers" 2
    Add-Paragraph "TLS bao ve tinh bi mat va toan ven cua du lieu tren duong truyen. Trong UTESHOP, Apache HTTP Server dong vai tro public-facing reverse proxy, nhan request HTTPS tu browser bang chung chi ZeroSSL. Sau khi ket thuc TLS, Apache chuyen request ve Jetty noi bo. Mo hinh nay giup tach thanh phan cong khai voi ung dung Java, dong thoi cho phep cau hinh security headers tai Apache nhu HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy va Content-Security-Policy."
    Add-ImagePlaceholder "Hinh 1. Kien truc trien khai Browser - Apache - Jetty - Database - External Services."
    Add-Heading "2.3. OpenID Connect va JWT" 2
    Add-Paragraph "OpenID Connect la lop xac thuc danh tinh xay tren OAuth2. Trong de tai, Google OIDC duoc dung de cho phep nguoi dung dang nhap bang tai khoan Google. Sau khi xac thuc thanh cong, ung dung tao session noi bo va JWT cookie. JWT giup ung dung luu thong tin phien dang nhap duoi dang token da ky, con cookie HttpOnly/Secure/SameSite giup giam nguy co token bi doc bang JavaScript hoac bi gui trong mot so tinh huong cross-site khong mong muon."
    Add-Heading "2.4. CSRF token va phan quyen ung dung" 2
    Add-Paragraph "CSRF la tan cong loi dung phien dang nhap cua nguoi dung de gui request thay doi trang thai tu mot website khac. UTESHOP trien khai CsrfFilter de bao ve cac POST quan trong nhu login, register, cart, order, profile, upload va payments/create-intent. Ngoai ra, PermissionFilter va AuthorizeFilter duoc dung de chan truy cap trai phep vao cac route nhay cam va route admin, dong thoi ghi log security event khi co truy cap bi tu choi."
    Add-Heading "2.5. BCrypt, OTP va rate limiting" 2
    Add-Paragraph "BCrypt la ham bam mat khau co salt va cost factor, phu hop hon cac ham hash thong thuong nhu MD5, SHA-1 hoac SHA-256 khi luu mat khau. Chuoi BCrypt da chua version, cost va salt, nen khi verify mat khau, thu vien BCrypt tu doc cac tham so nay tu chuoi hash. UTESHOP ket hop BCrypt voi OTP email, lockout tai khoan va rate limiting cho login/OTP de giam nguy co brute force."
    Add-Heading "2.6. Stripe Test Mode va tokenization" 2
    Add-Paragraph "Stripe Test Mode la moi truong sandbox cho phep kiem thu thanh toan bang the test ma khong xu ly tien that. Ung dung su dung Stripe.js va Stripe Elements de hien thi o nhap the an toan tren frontend. Server tao PaymentIntent qua Stripe API va chi nhan lai paymentIntentId, brand, last4 va status. Mo hinh nay giam pham vi tiep xuc cua ung dung voi du lieu the, vi PAN day du va CVV khong duoc luu trong database cua UTESHOP."
    Add-Heading "2.7. Vault KV, Vault Agent va Vault Transit" 2
    Add-Paragraph "HashiCorp Vault la cong cu quan ly secret va cung cap nhieu secrets engine. Trong de tai, Vault KV duoc dung de luu cac secret cau hinh nhu DB password, Stripe secret key, Google client secret, SMTP password va JWT secret. Vault Agent render cac secret nay thanh file runtime de ung dung doc khi khoi dong. Vault Transit duoc dung nhu mot trinh gia lap KMS: ung dung gui plaintext den Vault de ma hoa va nhan ve ciphertext, trong khi key material khong duoc xuat ra ung dung."
    Add-Heading "2.8. Docker, Envoy, Keycloak va PostgreSQL" 2
    Add-Paragraph "Docker Compose duoc dung de mo phong moi truong production-like gom nhieu container. Envoy dong vai tro API Gateway/reverse proxy, Keycloak dong vai tro Identity Provider, PostgreSQL dong vai tro database quan he, Vault dong vai tro secret/KMS service, con uteshop-web la ung dung hien tai. Kien truc nay chua phai microservices day du, nhung la buoc nen hop ly truoc khi tach cac service san pham, gio hang, don hang va thanh toan."

    Add-Heading "CHUONG 3: THIET KE VA TRIEN KHAI HE THONG" 1
    Add-Heading "3.1. Kien truc tong the" 2
    Add-Paragraph "Kien truc UTESHOP duoc chia thanh ba vung chinh. Vung public gom browser va Internet. Vung gateway gom Apache trong moi truong public domain hoac Envoy trong moi truong Docker production-like. Vung ung dung gom Jetty/UTEShop Web, database va Vault. Cac dich vu ben ngoai gom Google OIDC, Stripe va SMTP."
    Add-Code "Browser -> Apache/Envoy Gateway -> Jetty UTESHOP Web -> PostgreSQL/MySQL`n                               -> Vault KV/Transit`n                               -> Google OIDC / Stripe / SMTP"
    Add-PictureIfExists $architectureSvgPath "Hinh 2. So do kien truc tong the cua UTESHOP Security Project." 16.5
    Add-Heading "3.2. Cau hinh HTTPS va hardening gateway" 2
    Add-Paragraph "Trong moi truong domain that, Apache tiep nhan request HTTPS tai cong 443, su dung chung chi ZeroSSL va reverse proxy ve Jetty noi bo. Jetty duoc cau hinh bind vao loopback khi chay local, giup nguoi dung ben ngoai khong truy cap truc tiep vao cong 8081/8443. Apache dong thoi them cac header bao mat nhu HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy va CSP. Khi tich hop Stripe, CSP can cho phep frame-src den https://js.stripe.com de Stripe Card Element hoat dong."
    Add-ImagePlaceholder "Hinh 3. Ket qua curl -I hien thi HTTPS va security headers tren domain UTESHOP."
    Add-Heading "3.3. Luong xac thuc nguoi dung" 2
    Add-Paragraph "UTEShop ho tro dang nhap local bang email/password va OTP, dong thoi co luong Google OIDC. Voi dang nhap local, mat khau duoc verify bang BCrypt. Neu xac thuc mat khau thanh cong, he thong gui OTP qua email va chi tao phien sau khi OTP hop le. Voi Google OIDC, server tao state, nonce va PKCE verifier, chuyen browser sang Google, nhan authorization code o callback, doi token va tao user/session noi bo."
    Add-Code "Login local: email/password -> BCrypt verify -> OTP email -> JWT cookie`nGoogle OIDC: start -> Google authorize -> callback code -> token exchange -> JWT cookie"
    Add-ImagePlaceholder "Hinh 4. Man hinh dang nhap va buoc OTP hoac Google OIDC."
    Add-Heading "3.4. Bao ve request bang CSRF token" 2
    Add-Paragraph "CsrfFilter duoc cai dat cho toan bo ung dung va chi bat buoc kiem tra token voi cac POST thay doi trang thai. Token duoc tao o backend, gan vao session va expose cho JSP. Moi form quan trong gui kem hidden input csrfToken. Neu token thieu hoac sai, server tra ve 403 va ghi event csrf_failed vao security audit log."
    Add-CodeBlock "Doan ma minh chung 1. CsrfFilter chan request POST thieu token." @"
if (requiresCsrfCheck(httpRequest) && !CsrfUtils.isValid(httpRequest)) {
    SecurityAuditLogger.log("csrf_failed", httpRequest,
            SecurityAuditLogger.fields("reason", "missing_or_invalid_token"));
    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token.");
    return;
}
"@
    Add-Heading "3.5. Security audit log va permission filter" 2
    Add-Paragraph "SecurityAuditLogger ghi cac su kien bao mat vao file logs/security-audit.log. Cac event quan trong gom login_failed, login_success, otp_failed, account_locked, csrf_failed, permission_denied, admin_action va payment_authorized. PermissionFilter bao ve cac route nhay cam nhu cart, orders, payments va account. AuthorizeFilter bao ve cac route /admin/* va ghi log khi anonymous user hoac user khong phai ADMIN truy cap admin."
    Add-CodeBlock "Doan ma minh chung 2. SecurityAuditLogger ghi event dang key=value." @"
SecurityAuditLogger.log("payment_authorized", req,
        SecurityAuditLogger.fields("gateway", "stripe",
                "paymentIntentId", intent.getId(),
                "cardLast4", cardLast4,
                "panRetained", false,
                "cvvRetained", false));
"@
    Add-ImagePlaceholder "Hinh 5. File security-audit.log ghi nhan login_failed va payment_authorized."
    Add-Heading "3.6. Quan ly secret bang Vault KV va Vault Agent" 2
    Add-Paragraph "Truoc khi co Vault, secret duoc doc tu environment variables hoac file config/secrets.properties. Sau khi tich hop Vault, cac gia tri nhu DB password, Google secret, Stripe secret key, SMTP password, JWT secret va cau hinh Vault Transit duoc luu trong Vault KV tai secret/uteshop/prod. Vault Agent su dung AppRole de dang nhap Vault va render template thanh C:/secure/uteshop/secrets.properties. Ung dung Java doc file runtime nay thong qua Uteshop secrets file."
    Add-Code "Vault KV secret/uteshop/prod -> Vault Agent -> C:/secure/uteshop/secrets.properties -> SecretsConfig -> Java App"
    Add-ImagePlaceholder "Hinh 6. Vault Agent authentication successful va render secrets.properties."
    Add-Heading "3.7. Ma hoa du lieu nhay cam bang Vault Transit" 2
    Add-Paragraph "Cac truong phone va address duoc gan JPA converter de ma hoa truoc khi luu vao database. Khi VAULT_TRANSIT_ENABLED=true, FieldEncryptionUtils goi Vault Transit encrypt/decrypt thay vi tu ma hoa bang key local. Ciphertext moi duoc luu dang vault:v..., trong khi code van ho tro giai ma du lieu cu dang ENC:v1 de dam bao tuong thich nguoc. Cach lam nay giup ung dung khong nam giu key material va mo phong mo hinh KMS trong production."
    Add-Code "App plaintext -> Vault Transit encrypt -> vault:v... -> Database`nDatabase vault:v... -> Vault Transit decrypt -> App plaintext"
    Add-CodeBlock "Doan ma minh chung 3. Entity User ma hoa phone/address bang converter." @"
@Column(unique = true, length = 512)
@Convert(converter = EncryptedStringConverter.class)
private String phone;

@Column(nullable = true, length = 1024)
@Convert(converter = EncryptedStringConverter.class)
private String address;
"@
    Add-CodeBlock "Doan ma minh chung 4. VaultTransitClient goi API encrypt/decrypt cua Vault." @"
public static String encrypt(String plaintext) {
    String encodedPlaintext = Base64.getEncoder()
            .encodeToString(plaintext.getBytes(StandardCharsets.UTF_8));
    Map<String, Object> response = post("/v1/transit/encrypt/" + transitKey(),
            Map.of("plaintext", encodedPlaintext));
    return (String) data(response).get("ciphertext");
}
"@
    Add-ImagePlaceholder "Hinh 7. Bang user/orders co phone hoac address dang vault:v..."
    Add-Heading "3.8. Tich hop Stripe Test Mode" 2
    Add-Paragraph "Trong luong checkout, frontend tai Stripe.js va dung Stripe Elements de hien thi Card Element. Khi nguoi dung bam Place Order, frontend goi /payments/create-intent. Server tao PaymentIntent tren Stripe voi idempotency key va metadata, tra clientSecret ve browser. Browser goi stripe.confirmCardPayment(clientSecret). Sau khi Stripe thanh cong, frontend gui paymentIntentId ve server. Server truy van lai Stripe de xac minh trang thai va luu giao dich vao payment_transaction."
    Add-Code "Checkout -> /payments/create-intent -> Stripe PaymentIntent -> clientSecret`nBrowser confirmCardPayment -> Stripe succeeded -> submit paymentIntentId -> DB stores pi_..., brand, last4, status"
    Add-CodeBlock "Doan ma minh chung 5. Server tao Stripe PaymentIntent." @"
Stripe.apiKey = StripeConfig.secretKey();

Map<String, Object> params = new HashMap<>();
params.put("amount", amountCents);
params.put("currency", StripeConfig.currency());
params.put("payment_method_types", List.of("card"));
params.put("metadata", metadata);

PaymentIntent intent = PaymentIntent.create(params, options);
"@
    Add-CodeBlock "Doan ma minh chung 6. Frontend xac nhan thanh toan bang Stripe.js." @"
const result = await stripe.confirmCardPayment(intent.clientSecret, {
    payment_method: { card: card }
});

document.getElementById('paymentIntentId').value = result.paymentIntent.id;
form.submit();
"@
    Add-ImagePlaceholder "Hinh 8. Trang checkout hien thi Stripe Card Element va the test 4242."
    Add-Heading "3.9. Docker Compose production-like stack" 2
    Add-Paragraph "De chuan bi cho huong microservices, de tai bo sung Dockerfile va docker-compose.yml. Stack production-like gom postgres, vault, vault-bootstrap, keycloak, uteshop-web va envoy. Trong giai doan nay, uteshop-web van la monolith, nhung duoc dat sau Envoy va ket noi toi PostgreSQL/Vault container. Keycloak duoc import realm uteshop va client uteshop-web de dung cho buoc tich hop OIDC tiep theo."
    Add-Code "docker compose --env-file .\\deploy\\production-like\\.env -f .\\deploy\\production-like\\docker-compose.yml up --build"
    Add-CodeBlock "Doan ma minh chung 7. Compose production-like chay PostgreSQL, Vault, Keycloak, UTESHOP Web va Envoy." @"
services:
  postgres:
    image: postgres:16
  vault:
    image: hashicorp/vault:latest
  keycloak:
    image: quay.io/keycloak/keycloak:26.6.4
  uteshop-web:
    build:
      context: ../..
  envoy:
    image: envoyproxy/envoy:v1.32-latest
"@
    Add-ImagePlaceholder "Hinh 9. Docker Compose stack dang chay cac container Envoy, Keycloak, Vault, PostgreSQL va UTESHOP Web."

    Add-Heading "CHUONG 4: KET QUA THUC NGHIEM VA DANH GIA" 1
    Add-Heading "4.1. Ket qua HTTPS va hardening" 2
    Add-Paragraph "Ket qua kiem tra bang curl cho thay domain HTTPS tra ve 200 OK va cac header bao mat. Jetty sau khi hardening chi listen tren 127.0.0.1 khi chay local, giup nguoi dung ben ngoai khong truy cap truc tiep cong noi bo. Khi di qua Apache, browser chi thay endpoint HTTPS public."
    Add-Table @("Noi dung kiem tra", "Ket qua mong doi", "Trang thai") @(
        @("HTTPS domain", "HTTP/1.1 200 OK", "Dat"),
        @("Security headers", "HSTS, nosniff, SAMEORIGIN, CSP", "Dat"),
        @("Jetty direct access", "Chi Apache goi duoc cong noi bo", "Dat trong moi truong local hardening"),
        @("Stripe CSP", "Cho phep frame-src https://js.stripe.com", "Dat sau khi bo sung CSP")
    )
    Add-Heading "4.2. Ket qua thanh toan Stripe Test Mode" 2
    Add-Paragraph "Thanh toan duoc kiem thu bang the test 4242 4242 4242 4242 trong Stripe Sandbox. Sau khi bam Place Order, he thong tao PaymentIntent, xac nhan thanh toan va luu giao dich vao bang payment_transaction. Ket qua database cho thay paymentToken va gatewayReference co dang pi_..., cardLast4 la 4242, cardBrand la VISA, status la AUTHORIZED, gatewayResponseCode la STRIPE_SUCCEEDED, panRetained bang 0 va cvvRetained bang 0."
    Add-Table @("Truong du lieu", "Gia tri quan sat", "Y nghia bao mat") @(
        @("paymentToken", "pi_...", "Chi luu token/ID giao dich, khong luu so the day du"),
        @("cardLast4", "4242", "Chi luu 4 so cuoi de doi soat"),
        @("cardBrand", "VISA", "Chi luu loai the"),
        @("status", "AUTHORIZED", "Thanh toan duoc gateway xac nhan"),
        @("gatewayResponseCode", "STRIPE_SUCCEEDED", "Stripe tra ve thanh cong"),
        @("panRetained", "0", "Ung dung khong luu PAN"),
        @("cvvRetained", "0", "Ung dung khong luu CVV")
    )
    Add-ImagePlaceholder "Hinh 10. Bang payment_transaction sau khi thanh toan thanh cong."
    Add-CodeBlock "Cau lenh SQL minh chung ket qua thanh toan." @"
SELECT
  paymentToken,
  cardLast4,
  cardBrand,
  amount,
  status,
  gatewayReference,
  gatewayResponseCode,
  panRetained,
  cvvRetained
FROM payment_transaction
ORDER BY _id DESC
LIMIT 5;
"@
    Add-Heading "4.3. Ket qua Vault KV va Vault Transit" 2
    Add-Paragraph "Vault Agent da dang nhap thanh cong bang AppRole, ghi token vao C:/secure/uteshop/vault-agent-token va render template secrets.properties. Sau khi bat Vault Transit, cac ban ghi moi cua phone/address duoc luu trong database voi tien to vault:v..., cho thay du lieu da duoc ma hoa thong qua Vault Transit thay vi luu plaintext."
    Add-Table @("Thanh phan", "Bang chung", "Danh gia") @(
        @("Vault KV", "secret/uteshop/prod luu DB, SMTP, Stripe, JWT, Google secret", "Secret khong hard-code trong source"),
        @("Vault Agent", "render C:/secure/uteshop/secrets.properties", "Ung dung doc secret runtime"),
        @("Vault Transit", "ciphertext dang vault:v...", "Khoa ma hoa khong xuat ra ung dung"),
        @("Database", "phone/address khong con plaintext", "Giam thieu rui ro khi DB bi lo")
    )
    Add-ImagePlaceholder "Hinh 11. Vault Agent log authentication successful va rendered template."
    Add-ImagePlaceholder "Hinh 12. Du lieu phone/address dang vault:v... trong database."
    Add-CodeBlock "Cau lenh SQL minh chung du lieu duoc ma hoa." @"
SELECT email, phone, address
FROM ""user""
ORDER BY _id DESC
LIMIT 5;
"@
    Add-Heading "4.4. Ket qua audit log, CSRF va permission" 2
    Add-Paragraph "He thong ghi log cac su kien bao mat vao logs/security-audit.log. Khi dang nhap sai, log co event login_failed. Khi CSRF token thieu hoac sai, log co event csrf_failed. Khi thanh toan thanh cong, log co event payment_authorized. Ngoai ra, PermissionFilter va AuthorizeFilter ghi log khi anonymous user hoac user khong du quyen truy cap route nhay cam."
    Add-Heading "4.5. Danh gia theo OWASP Top 10 lien quan online shopping" 2
    Add-Table @("Nhom rui ro", "Nguy co trong online shopping", "Co che trong UTESHOP") @(
        @("Broken Access Control", "User truy cap admin/order/payment trai phep", "AuthorizeFilter, PermissionFilter, audit log"),
        @("Cryptographic Failures", "Lo phone/address/payment data", "TLS, Vault Transit, khong luu PAN/CVV"),
        @("Injection", "Input tac dong toi query", "JPA parameterized query la chinh"),
        @("Identification and Authentication Failures", "Brute force, stolen session", "BCrypt, OTP, JWT cookie, rate limiting"),
        @("Security Misconfiguration", "Header thieu, cong noi bo bi mo", "Apache security headers, Jetty bind noi bo"),
        @("Software and Data Integrity Failures", "Webhook gia mao", "Stripe webhook signature verification"),
        @("Security Logging and Monitoring Failures", "Khong co bang chung su kien", "security-audit.log")
    )
    Add-Heading "4.6. Han che hien tai" 2
    Add-Paragraph "Mac du prototype da co nhieu co che production-like, he thong van con mot so gioi han. Keycloak moi duoc dua vao Docker stack, chua thay the hoan toan luong login hien tai. Microservices chua duoc tach rieng, Envoy hien moi route ve monolith. Vault trong Docker stack dung dev mode nen chi phu hop local testing. Viec migrate du lieu cu tu MySQL sang PostgreSQL can can nhac ciphertext Vault Transit, vi du lieu vault:v... phu thuoc vao key trong Vault."

    Add-Heading "CHUONG 5: HUONG DAN CAI DAT VA KIEM THU" 1
    Add-Heading "5.1. Chay ung dung local hien tai" 2
    Add-Paragraph "Khi chay local ngoai Docker, can dam bao Vault server, Vault Agent va Jetty dang chay. File secret runtime duoc dat tai C:/secure/uteshop/secrets.properties va bien UTESHOP_SECRETS_FILE tro toi file nay."
    Add-Code "vault server -config=\"vault/vault-server-local.example.hcl\"`nvault agent -config=\"vault/vault-agent.example.hcl\"`nmvn jetty:run"
    Add-Heading "5.2. Chay production-like stack" 2
    Add-Paragraph "Khi chay bang Docker Compose, can tao file .env tu .env.example va dien cac secret can thiet. Stack se khoi dong PostgreSQL, Vault dev, Vault bootstrap, Keycloak, uteshop-web va Envoy."
    Add-Code "Copy-Item .\\deploy\\production-like\\.env.example .\\deploy\\production-like\\.env`ndocker compose --env-file .\\deploy\\production-like\\.env -f .\\deploy\\production-like\\docker-compose.yml up --build"
    Add-Heading "5.3. Kiem thu thanh toan" 2
    Add-Paragraph "De kiem thu thanh toan, can cau hinh Stripe publishable key va secret key that trong sandbox. Sau khi vao checkout qua HTTPS hoac Envoy, nhap the test 4242 4242 4242 4242, expiry 12/34 va CVC 123. Sau khi thanh toan thanh cong, kiem tra bang payment_transaction."
    Add-Code "SELECT paymentToken, cardLast4, cardBrand, amount, status, gatewayReference, gatewayResponseCode, panRetained, cvvRetained, createdAt FROM payment_transaction ORDER BY _id DESC LIMIT 5;"
    Add-Heading "5.4. Kiem thu ma hoa du lieu" 2
    Add-Paragraph "De kiem thu Vault Transit, cap nhat phone hoac address cua user, sau do xem database. Neu du lieu moi co dang vault:v... thi app da dung Vault Transit. Du lieu cu dang ENC:v1 van co the ton tai do he thong ho tro giai ma nguoc tu co che AES-GCM cu."
    Add-Code "SELECT email, phone, address FROM \"user\" ORDER BY _id DESC LIMIT 5;"
    Add-Heading "5.5. Kiem thu audit log" 2
    Add-Paragraph "Kiem thu bang cach dang nhap sai mat khau, gui request thieu CSRF token hoac checkout thanh cong. Sau do doc file logs/security-audit.log de doi chieu event."
    Add-Code "Get-Content logs/security-audit.log -Tail 50"

    Add-Heading "CHUONG 6: KET LUAN VA HUONG PHAT TRIEN" 1
    Add-Heading "6.1. Ket luan" 2
    Add-Paragraph "De tai da xay dung duoc mot prototype thuong mai dien tu UTESHOP co tich hop nhieu co che bao mat quan trong. He thong bao ve kenh truyen bang HTTPS, quan ly phien bang JWT cookie, xac thuc nguoi dung qua BCrypt/OTP va Google OIDC, bao ve request bang CSRF token, ghi security audit log, ma hoa du lieu nhay cam bang Vault Transit va tich hop Stripe Test Mode de mo phong thanh toan tokenization khong luu PAN/CVV."
    Add-Paragraph "Ket qua thuc nghiem cho thay he thong luu giao dich thanh toan theo dang pi_..., chi luu brand va last4, dong thoi panRetained va cvvRetained bang 0. Du lieu phone/address moi duoc luu dang vault:v..., chung minh ung dung da chuyen sang co che ma hoa thong qua Vault Transit. Docker Compose stack voi Envoy, Keycloak, PostgreSQL, Vault va uteshop-web tao nen nen tang de tiep tuc phat trien theo huong production-like va microservices."
    Add-Heading "6.2. Huong phat trien" 2
    Add-Paragraph "Huong phat trien tiep theo la hoan thien Keycloak OIDC login va gan Envoy voi JWT validation. Sau do, he thong co the tach payment-service dau tien, vi thanh toan co boundary ro va co gia tri bao mat cao. Cac service tiep theo la catalog-service, cart-service va order-service. Khi tach service, can thiet ke database ownership, API contract, service-to-service authentication, mTLS hoac signed requests, idempotency, observability va chinh sach rotate secret/key."
    Add-Paragraph "Ngoai ra, Vault trong moi truong Docker can duoc thay bang Vault production mode voi storage ben vung va seal/unseal an toan, hoac tich hop Cloud KMS nhu GCP KMS/AWS KMS/Azure Key Vault. Stripe webhook can duoc cau hinh bang webhook secret that trong dashboard sandbox. Cuoi cung, can bo sung automated security test bang OWASP ZAP, dependency scanning va benchmark latency cho cac luong login, checkout va encrypt/decrypt."

    Add-Heading "PHU LUC: DANH SACH ANH MINH CHUNG CAN CHEN" 1
    Add-Table @("STT", "Anh minh chung", "Vi tri nen chen") @(
        @("1", "Kien truc he thong UTESHOP Deployment Architecture", "Chuong 3.1"),
        @("2", "curl -I HTTPS co security headers", "Chuong 4.1"),
        @("3", "Trang checkout co Stripe Card Element", "Chuong 3.8 / 4.2"),
        @("4", "Stripe Dashboard Sandbox co payment succeeded", "Chuong 4.2"),
        @("5", "Bang payment_transaction voi pi_..., last4, panRetained=0, cvvRetained=0", "Chuong 4.2"),
        @("6", "Vault Agent rendered C:/secure/uteshop/secrets.properties", "Chuong 4.3"),
        @("7", "Bang user/orders co phone/address dang vault:v...", "Chuong 4.3"),
        @("8", "logs/security-audit.log co payment_authorized/login_failed/csrf_failed", "Chuong 4.4"),
        @("9", "Docker Desktop hien cac container envoy, keycloak, vault, postgres, uteshop-web", "Chuong 3.9"),
        @("10", "Keycloak realm uteshop va client uteshop-web", "Chuong 3.9 / 6.2")
    )

    foreach ($toc in $doc.TablesOfContents) {
        $toc.Update()
    }

    if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Force
    }
    $doc.SaveAs2($outputPath, $wdFormatDocumentDefault)
    $doc.Close($false)
    Write-Output $outputPath
} finally {
    $word.Quit() | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
