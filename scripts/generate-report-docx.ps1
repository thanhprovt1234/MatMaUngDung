$ErrorActionPreference = "Stop"

$outputPath = "D:\MMUD\THIẾT KẾ VÀ TRIỂN KHAI PROTOTYPE BẢO MẬT CHO NỀN TẢNG THƯƠNG MẠI ĐIỆN TỬ_formatted.docx"
$sourcePath = "D:\MMUD\THIẾT KẾ VÀ TRIỂN KHAI PROTOTYPE BẢO MẬT CHO NỀN TẢNG THƯƠNG MẠI ĐIỆN TỬ.docx"
$backupPath = "D:\MMUD\THIẾT KẾ VÀ TRIỂN KHAI PROTOTYPE BẢO MẬT CHO NỀN TẢNG THƯƠNG MẠI ĐIỆN TỬ.backup.docx"

if ((Test-Path -LiteralPath $sourcePath) -and -not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $sourcePath -Destination $backupPath -Force
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

$wdFormatDocumentDefault = 16
$wdStory = 6
$wdPageBreak = 7
$wdCollapseEnd = 0
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
        $selection.ParagraphFormat.Alignment = $wdAlignCenter
        $selection.ParagraphFormat.FirstLineIndent = 0
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-Heading([string] $text, [int] $level = 1) {
        $styleName = "Heading $level"
        $selection.Style = $doc.Styles.Item($styleName)
        $selection.Font.Name = "Times New Roman"
        $selection.Font.Bold = $true
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

    Add-Centered "TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN" 13 $true
    Add-Centered "KHOA MẠNG MÁY TÍNH VÀ TRUYỀN THÔNG" 13 $true
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    Add-Centered "BÁO CÁO TỔNG KẾT ĐỒ ÁN" 16 $true
    Add-Centered "MÔN HỌC: NT219 - CRYPTOGRAPHY" 14 $true
    $selection.TypeParagraph()
    Add-Centered "THIẾT KẾ VÀ TRIỂN KHAI PROTOTYPE BẢO MẬT CHO NỀN TẢNG THƯƠNG MẠI ĐIỆN TỬ" 16 $true
    $selection.TypeParagraph()
    Add-Centered "Prototype: UTEShop - Online Shopping Service Platform" 13 $false
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    Add-Centered "Sinh viên thực hiện: Nguyễn Xuân Thành" 13 $false
    Add-Centered "Công nghệ: Java Servlet/JSP, Jetty, Apache, MySQL, Google OIDC, JWT, AES-GCM, ZeroSSL" 13 $false
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    Add-Centered "TP. Hồ Chí Minh, 2026" 13 $false
    Add-PageBreak

    Add-Heading "LỜI CAM ĐOAN" 1
    Add-Paragraph "Tôi cam đoan báo cáo này được xây dựng dựa trên quá trình nghiên cứu, triển khai và kiểm thử prototype UTEShop trong phạm vi môn học NT219 - Cryptography. Các nội dung trình bày trong báo cáo phản ánh kết quả thực hiện của hệ thống ở mức prototype phục vụ học thuật. Những khái niệm, công nghệ và chuẩn bảo mật được sử dụng nhằm minh họa cách ứng dụng mật mã trong một hệ thống thương mại điện tử, không nhằm khẳng định hệ thống đã đạt chứng nhận production hoặc chứng nhận tuân thủ đầy đủ như PCI DSS."
    Add-PageBreak

    Add-Heading "LỜI CẢM ƠN" 1
    Add-Paragraph "Tôi xin gửi lời cảm ơn đến giảng viên phụ trách môn học đã định hướng đề tài theo hướng gắn lý thuyết mật mã với các tình huống ứng dụng thực tế. Trong quá trình thực hiện, đề tài giúp tôi hiểu rõ hơn vai trò của TLS, OpenID Connect, JWT, mã hóa dữ liệu ở trạng thái lưu trữ và tokenization trong luồng thanh toán. Bên cạnh kết quả triển khai, quá trình khắc phục lỗi cấu hình, dữ liệu mẫu, chứng chỉ và database cũng giúp tôi tiếp cận gần hơn với các vấn đề thường gặp khi đưa một ứng dụng web vào môi trường demo thực tế."
    Add-PageBreak

    Add-Heading "MỤC LỤC" 1
    $tocRange = $selection.Range
    $doc.TablesOfContents.Add($tocRange, $true, 1, 3) | Out-Null
    $selection.EndKey($wdStory) | Out-Null
    Add-PageBreak

    Add-Heading "DANH MỤC TỪ VIẾT TẮT" 1
    Add-Table @("Từ viết tắt", "Ý nghĩa") @(
        @("TLS", "Transport Layer Security"),
        @("OIDC", "OpenID Connect"),
        @("JWT", "JSON Web Token"),
        @("PKCE", "Proof Key for Code Exchange"),
        @("PAN", "Primary Account Number"),
        @("CVV", "Card Verification Value"),
        @("PII", "Personally Identifiable Information"),
        @("KMS", "Key Management Service"),
        @("HSM", "Hardware Security Module")
    )
    Add-PageBreak

    Add-Heading "TÓM TẮT" 1
    Add-Paragraph "Thương mại điện tử là một loại hệ thống web xử lý đồng thời nhiều nhóm dữ liệu nhạy cảm, bao gồm tài khoản người dùng, thông tin giao hàng, giỏ hàng, đơn hàng và dữ liệu thanh toán. Nếu không có thiết kế bảo mật phù hợp, hệ thống có thể đối mặt với các rủi ro như nghe lén lưu lượng, đánh cắp phiên đăng nhập, rò rỉ dữ liệu cá nhân trong cơ sở dữ liệu hoặc lưu trữ dữ liệu thẻ sai cách."
    Add-Paragraph "Báo cáo này trình bày quá trình thiết kế và triển khai prototype UTEShop với trọng tâm là ứng dụng các cơ chế mật mã và bảo mật web trong những luồng nghiệp vụ quan trọng. Hệ thống được cấu hình với Apache reverse proxy, TLS sử dụng chứng chỉ ZeroSSL, xác thực Google OpenID Connect theo Authorization Code Flow kết hợp PKCE, quản lý phiên bằng JWT cookie an toàn, mã hóa dữ liệu nhạy cảm cấp trường bằng AES-256-GCM và mô phỏng thanh toán tokenization theo định hướng PCI DSS."
    Add-Paragraph "Kết quả thực nghiệm cho thấy hệ thống có thể thực hiện luồng mua hàng hoàn chỉnh từ thêm sản phẩm vào giỏ, checkout, nhập thông tin thẻ thử nghiệm, tạo payment token, tạo đơn hàng và lưu dữ liệu nhạy cảm ở dạng mã hóa. Trong cơ sở dữ liệu, thông tin địa chỉ và số điện thoại được lưu dưới dạng ENC:v1, còn giao dịch thanh toán chỉ lưu token, loại thẻ và bốn số cuối. Điều này thể hiện được nguyên tắc giảm thiểu dữ liệu nhạy cảm khi lưu trữ và giảm rủi ro khi cơ sở dữ liệu bị lộ."

    Add-Heading "CHƯƠNG 1. MỞ ĐẦU" 1
    Add-Heading "1.1. Lý do chọn đề tài" 2
    Add-Paragraph "Các nền tảng mua sắm trực tuyến như Shopee, Amazon hoặc những hệ thống thương mại điện tử nội bộ đều phải xử lý dữ liệu có giá trị cao. Trong một phiên giao dịch thông thường, người dùng đăng nhập, duyệt sản phẩm, thêm hàng vào giỏ, nhập địa chỉ, đặt đơn và thực hiện thanh toán. Mỗi bước trong chuỗi nghiệp vụ này đều có thể trở thành điểm tấn công nếu hệ thống không được thiết kế theo nguyên tắc bảo mật ngay từ đầu."
    Add-Paragraph "Đối với môn học Cryptography, thương mại điện tử là bối cảnh phù hợp để quan sát cách các cơ chế mật mã được sử dụng trong thực tế. TLS bảo vệ kênh truyền, OIDC hỗ trợ xác thực liên miền, JWT và cookie bảo vệ phiên đăng nhập, AES-GCM bảo vệ dữ liệu ở trạng thái lưu trữ, còn tokenization giúp giảm rủi ro khi xử lý dữ liệu thẻ. Vì vậy, đề tài lựa chọn xây dựng một prototype thương mại điện tử nhằm minh họa các kỹ thuật này trong một hệ thống có luồng nghiệp vụ end-to-end."

    Add-Heading "1.2. Mục tiêu nghiên cứu" 2
    Add-Paragraph "Mục tiêu của đề tài là thiết kế và triển khai một prototype thương mại điện tử có thể chứng minh được các cơ chế bảo mật quan trọng trong luồng xác thực, lưu trữ dữ liệu và thanh toán. Hệ thống cần có khả năng vận hành qua HTTPS với chứng chỉ được cấp bởi CA, hỗ trợ đăng nhập Google SSO theo OIDC Authorization Code Flow kết hợp PKCE, quản lý phiên bằng JWT cookie an toàn, mã hóa dữ liệu nhạy cảm bằng AES-GCM và mô phỏng thanh toán tokenization theo định hướng không lưu PAN hoặc CVV."
    Add-Paragraph "Ngoài phần triển khai, đề tài cũng đặt mục tiêu đánh giá hệ thống theo góc nhìn security posture. Thay vì chỉ kiểm tra chức năng, báo cáo phân tích thêm rủi ro còn lại, trade-off về hiệu năng, chi phí triển khai và hướng mở rộng nếu hệ thống được phát triển theo kiến trúc production-like."

    Add-Heading "1.3. Phạm vi thực hiện" 2
    Add-Paragraph "Đề tài được triển khai ở mức prototype phục vụ học thuật. Hệ thống không xử lý thẻ thanh toán thật và không kết nối đến payment gateway production. Các chức năng như KMS, HSM, Vault, Kubernetes, mTLS hoặc fraud scoring được trình bày dưới góc độ phân tích và hướng phát triển, chưa phải thành phần triển khai đầy đủ trong prototype. Phạm vi thực nghiệm tập trung vào Java Web Application chạy bằng Jetty, Apache HTTP Server làm reverse proxy, MySQL lưu trữ dữ liệu, Google OIDC cho xác thực và AES-GCM cho mã hóa cấp trường."

    Add-Heading "CHƯƠNG 2. CƠ SỞ LÝ THUYẾT" 1
    Add-Heading "2.1. TLS và chứng chỉ số" 2
    Add-Paragraph "TLS là giao thức bảo vệ kênh truyền giữa trình duyệt và máy chủ. Khi website sử dụng HTTPS, dữ liệu được mã hóa trong quá trình truyền, giúp chống nghe lén và giảm khả năng bị chỉnh sửa nội dung trên đường truyền. TLS còn giúp browser xác thực server thông qua chứng chỉ số do Certificate Authority cấp. Trong prototype, domain uteshop.kesug.com được cấu hình với chứng chỉ ZeroSSL trên Apache, sau đó Apache chuyển tiếp request về ứng dụng Java chạy nội bộ trên Jetty."
    Add-Code "Browser --HTTPS/ZeroSSL--> Apache HTTP Server --HTTP local--> Jetty Java Web App --JPA/Hibernate--> MySQL"

    Add-Heading "2.2. OAuth2, OpenID Connect và PKCE" 2
    Add-Paragraph "OAuth2 là framework ủy quyền, còn OpenID Connect mở rộng OAuth2 để phục vụ xác thực danh tính. Trong luồng Authorization Code, Google không trả token trực tiếp về browser mà trả về authorization code. Server nhận code và đổi lấy token tại token endpoint. PKCE bổ sung code verifier và code challenge nhằm giảm rủi ro nếu authorization code bị chặn trong quá trình redirect. Trong hệ thống UTEShop, server tạo state, nonce và code verifier trước khi chuyển người dùng sang Google, sau đó kiểm tra lại các giá trị này ở callback trước khi tạo session nội bộ."

    Add-Heading "2.3. JWT cookie và bảo vệ phiên đăng nhập" 2
    Add-Paragraph "JWT được sử dụng để biểu diễn phiên đăng nhập nội bộ sau khi người dùng đăng nhập thường hoặc đăng nhập bằng Google. Token được lưu trong cookie thay vì lưu trong localStorage. Cookie được cấu hình HttpOnly để JavaScript không đọc được qua document.cookie, Secure để cookie chỉ gửi qua HTTPS, và SameSite=Lax để giảm rủi ro CSRF trong các tình huống cross-site phổ biến. Đây không phải là cơ chế thay thế hoàn toàn CSP hoặc CSRF token, nhưng là lớp bảo vệ quan trọng cho phiên đăng nhập."

    Add-Heading "2.4. AES-GCM và mã hóa cấp trường" 2
    Add-Paragraph "AES-GCM là chế độ mã hóa đối xứng cung cấp đồng thời tính bí mật và tính toàn vẹn dữ liệu. Nếu ciphertext hoặc authentication tag bị thay đổi, quá trình giải mã sẽ thất bại. Trong prototype, AES-256-GCM được áp dụng ở cấp trường thông qua JPA AttributeConverter. Các trường như địa chỉ và số điện thoại được mã hóa trước khi lưu database, với định dạng ENC:v1 gồm phiên bản, IV và ciphertext kèm tag. Khóa mã hóa được nạp từ biến môi trường FIELD_ENCRYPTION_KEY thay vì hard-code trong source code."

    Add-Heading "2.5. Tokenization và định hướng PCI DSS" 2
    Add-Paragraph "Trong thanh toán thẻ, PAN là số thẻ đầy đủ còn CVV là mã xác thực nhạy cảm. Theo tinh thần PCI DSS, hệ thống thương mại điện tử nên hạn chế tối đa việc lưu trữ dữ liệu thẻ, đặc biệt không lưu CVV sau authorization. Tokenization thay thế dữ liệu thẻ bằng một token đại diện. Token có thể được lưu để tham chiếu giao dịch, trong khi PAN và CVV không nằm trong database của merchant. Prototype mô phỏng payment gateway bằng cách validate thẻ test, sinh token dạng pay_tok, chỉ lưu brand và bốn số cuối."

    Add-Heading "CHƯƠNG 3. NGỮ CẢNH HỆ THỐNG, RỦI RO VÀ MỤC TIÊU BẢO MẬT" 1
    Add-Heading "3.1. Ngữ cảnh nghiệp vụ và phạm vi bảo vệ" 2
    Add-Paragraph "UTEShop được đặt trong ngữ cảnh một nền tảng thương mại điện tử cho phép người dùng đăng nhập, xem sản phẩm, thêm hàng vào giỏ, đặt hàng và thực hiện thanh toán thử nghiệm. Hệ thống có ba nhóm chủ thể chính: khách hàng sử dụng trình duyệt, quản trị viên vận hành dữ liệu sản phẩm và đơn hàng, cùng các hệ thống bên ngoài như Google Identity Provider và mock payment gateway. Vì đây là prototype học thuật, hệ thống không xử lý thẻ thật và không khẳng định đạt chứng nhận PCI DSS đầy đủ; mục tiêu là mô phỏng đúng các nguyên tắc bảo vệ dữ liệu quan trọng trong một luồng thương mại điện tử."
    Add-Paragraph "Phạm vi bảo vệ của báo cáo tập trung vào các điểm tiếp xúc có rủi ro cao: kênh truyền giữa browser và server, phiên đăng nhập, dữ liệu cá nhân lưu trong database, dữ liệu thẻ xuất hiện trong bước checkout và các secret dùng để kết nối hoặc mã hóa. Những thành phần nằm ngoài phạm vi prototype như hạ tầng cloud production, hệ thống chống gian lận bằng machine learning, HSM hoặc payment gateway thật được trình bày như hướng phát triển."

    Add-Heading "3.2. Trust boundary và giả định an toàn" 2
    Add-Paragraph "Trong mô hình bảo mật của hệ thống, browser và mạng Internet được xem là vùng không tin cậy hoàn toàn. Người dùng có thể bị lừa truy cập trang độc hại, request có thể đi qua môi trường mạng công cộng và dữ liệu nhập từ form có thể chứa giá trị không hợp lệ. Apache là điểm nhận request từ Internet và là nơi kết thúc TLS. Jetty chạy ứng dụng Java trong vùng nội bộ, MySQL là kho dữ liệu cần được bảo vệ, còn Google được xem là Identity Provider tin cậy trong phạm vi xác thực OIDC."
    Add-Code "Untrusted Zone: Browser + Internet`nTrust Boundary: HTTPS/TLS at Apache`nInternal Zone: Jetty Java App + MySQL`nExternal Trusted Provider: Google OIDC`nExternal Simulated Provider: Mock Payment Gateway"

    Add-Heading "3.3. Tài sản cần bảo vệ" 2
    Add-Paragraph "Các tài sản quan trọng của hệ thống gồm tài khoản người dùng, quyền admin, JWT token, email, địa chỉ, số điện thoại, giỏ hàng, đơn hàng, trạng thái thanh toán, dữ liệu thẻ nhập tạm thời trong quá trình checkout, khóa mã hóa FIELD_ENCRYPTION_KEY, Google OAuth client secret và thông tin kết nối database. Trong đó, JWT token ảnh hưởng trực tiếp đến quyền truy cập phiên; địa chỉ và số điện thoại là dữ liệu cá nhân; còn PAN và CVV là dữ liệu thanh toán nhạy cảm không nên lưu trong database của ứng dụng."

    Add-Heading "3.4. Mô hình rủi ro" 2
    Add-Paragraph "Rủi ro được xác định dựa trên các luồng nghiệp vụ chính thay vì chỉ liệt kê theo công nghệ. Khi người dùng đăng nhập, nguy cơ chính là đánh cắp phiên hoặc brute force. Khi người dùng checkout, nguy cơ chuyển sang lộ dữ liệu cá nhân và dữ liệu thẻ. Khi dữ liệu được lưu trong MySQL, nguy cơ quan trọng là lộ plaintext nếu database bị truy cập trái phép. Bảng dưới đây mô tả mối liên hệ giữa rủi ro, tác động và cơ chế giảm thiểu trong prototype."
    Add-Table @("Rủi ro", "Tác động", "Cơ chế giảm thiểu trong prototype") @(
        @("Nghe lén hoặc sửa đổi traffic", "Lộ cookie, dữ liệu đăng nhập và dữ liệu checkout", "HTTPS với chứng chỉ ZeroSSL tại Apache"),
        @("Đánh cắp JWT qua script độc hại", "Chiếm phiên đăng nhập của người dùng", "Cookie HttpOnly, Secure và SameSite=Lax"),
        @("Lộ cơ sở dữ liệu", "Lộ địa chỉ, số điện thoại và thông tin đơn hàng", "Mã hóa address và phone bằng AES-256-GCM"),
        @("Lưu PAN hoặc CVV", "Tăng phạm vi rủi ro PCI DSS và hậu quả khi DB bị lộ", "Tokenization, chỉ lưu last4, brand và payment token"),
        @("Brute force login/OTP", "Chiếm tài khoản hoặc spam luồng xác thực", "Rate limiting, OTP và lockout cơ bản"),
        @("Lộ khóa mã hóa hoặc secret", "Có thể giải mã dữ liệu hoặc giả mạo tích hợp", "Secret lấy từ biến môi trường, định hướng Vault/KMS")
    )

    Add-Heading "3.5. Mục tiêu bảo mật" 2
    Add-Paragraph "Từ ngữ cảnh và rủi ro trên, hệ thống đặt ra các mục tiêu bảo mật cụ thể. Các mục tiêu này đóng vai trò cầu nối giữa yêu cầu nghiệp vụ và kiến trúc giải pháp, giúp tránh nhầm lẫn giữa việc triển khai công cụ với việc giải quyết rủi ro."
    Add-Table @("Mục tiêu bảo mật", "Ý nghĩa", "Cơ chế triển khai") @(
        @("Bảo vệ kênh truyền", "Dữ liệu giữa browser và server không bị đọc hoặc sửa dễ dàng trên mạng", "TLS/HTTPS với chứng chỉ ZeroSSL"),
        @("Xác thực người dùng an toàn", "Giảm rủi ro tự quản lý mật khẩu và hỗ trợ SSO", "Google OIDC Authorization Code Flow + PKCE"),
        @("Bảo vệ phiên đăng nhập", "Giảm khả năng token bị đọc bởi script phía client", "JWT cookie HttpOnly, Secure, SameSite=Lax"),
        @("Bảo vệ dữ liệu lưu trữ", "Database bị lộ không làm lộ ngay địa chỉ và số điện thoại plaintext", "AES-256-GCM field-level encryption"),
        @("Giảm rủi ro dữ liệu thẻ", "Ứng dụng không lưu PAN/CVV sau authorization", "Mock payment tokenization"),
        @("Giảm lạm dụng API xác thực", "Hạn chế brute force và spam OTP", "Rate limiting và lockout cơ bản")
    )

    Add-Heading "CHƯƠNG 4. KIẾN TRÚC GIẢI PHÁP VÀ KỊCH BẢN TRIỂN KHAI" 1
    Add-Heading "4.1. Kiến trúc logic của giải pháp" 2
    Add-Paragraph "Kiến trúc logic mô tả các khối chức năng và quan hệ bảo mật giữa chúng, không phụ thuộc vào việc hệ thống đang chạy trên máy local hay server thật. Ở mức logic, browser chỉ là client gửi request; UTEShop App chịu trách nhiệm xử lý nghiệp vụ, tạo phiên, mã hóa dữ liệu và điều phối checkout; Google OIDC chịu trách nhiệm xác thực danh tính; mock payment gateway mô phỏng bước tokenization; MySQL lưu dữ liệu người dùng, giỏ hàng, đơn hàng và giao dịch thanh toán đã được giảm thiểu dữ liệu nhạy cảm."
    Add-Code "Browser Client`n  -> UTEShop Web App`n      -> Google OIDC for identity verification`n      -> Mock Payment Gateway for tokenization`n      -> MySQL for users, carts, orders, payment tokens"
    Add-Table @("Khối logic", "Vai trò", "Cơ chế bảo mật liên quan") @(
        @("Browser Client", "Hiển thị giao diện và gửi request", "Nhận cookie HttpOnly/Secure, giao tiếp qua HTTPS"),
        @("UTEShop App", "Xử lý authentication, cart, order và payment", "Verify OIDC, ký JWT, gọi AES-GCM, tokenization"),
        @("Google OIDC", "Xác thực danh tính người dùng", "Authorization Code Flow + PKCE, ID Token verification"),
        @("Mock Payment Gateway", "Mô phỏng xử lý thẻ và sinh token", "Không trả PAN/CVV về database"),
        @("MySQL", "Lưu dữ liệu ứng dụng", "Lưu ciphertext và payment token thay vì plaintext/PAN")
    )

    Add-Heading "4.2. Kiến trúc network và host" 2
    Add-Paragraph "Kiến trúc network/host mô tả cách các thành phần được đặt trên môi trường chạy thực tế. Trong prototype, Apache HTTP Server là host-facing component nhận request từ browser qua domain uteshop.kesug.com. Apache kết thúc TLS bằng chứng chỉ ZeroSSL, sau đó reverse proxy request về Jetty chạy ở cổng nội bộ 8081. MySQL được sử dụng làm database phía sau ứng dụng. Cách tách này giúp phân biệt rõ server công khai nhận HTTPS với app server nội bộ xử lý logic."
    Add-Code "Internet Browser`n  -- HTTPS :443, ZeroSSL --> Apache HTTP Server`n  -- HTTP localhost:8081 --> Jetty Maven Plugin / UTEShop`n  -- JDBC localhost:3306 --> MySQL"

    Add-Heading "4.3. Kịch bản triển khai" 2
    Add-Paragraph "Kịch bản triển khai là cách hiện thực hóa kiến trúc trong môi trường demo, không phải bản thân kiến trúc bảo mật. Trong kịch bản hiện tại, domain uteshop.kesug.com được trỏ về máy chạy Apache. Apache được cấu hình virtual host HTTPS, nạp certificate ZeroSSL và reverse proxy về ứng dụng Java ở http://127.0.0.1:8081/uteshop. Jetty Maven Plugin chạy ứng dụng Java Servlet/JSP, còn MySQL lưu dữ liệu nghiệp vụ. Khi báo cáo kết quả, cần trình bày rõ đây là môi trường triển khai prototype, không nhầm với kiến trúc logic của giải pháp."

    Add-Heading "4.4. Data flow đăng nhập Google OIDC" 2
    Add-Paragraph "Luồng đăng nhập Google bắt đầu khi người dùng bấm đăng nhập bằng Google. UTEShop tạo state, nonce và PKCE code verifier, sau đó chuyển browser sang Google authorization endpoint. Sau khi Google xác thực người dùng, browser được redirect về callback của UTEShop cùng authorization code. Server kiểm tra state, dùng code và code verifier để đổi token, verify ID Token bằng khóa công khai của Google, sau đó tạo session nội bộ và JWT cookie. Trong luồng này, mật khẩu Google không đi qua UTEShop, còn authorization code không đủ giá trị nếu thiếu code verifier."
    Add-Code "User -> UTEShop: Login with Google`nUTEShop -> Google: authorization request + code_challenge`nGoogle -> UTEShop callback: authorization_code`nUTEShop -> Google: code + code_verifier`nGoogle -> UTEShop: ID Token`nUTEShop -> Browser: internal JWT cookie"

    Add-Heading "4.5. Data flow checkout và tokenization" 2
    Add-Paragraph "Luồng checkout tập trung vào nguyên tắc không lưu dữ liệu thẻ nhạy cảm. Người dùng nhập địa chỉ, số điện thoại và thông tin thẻ test trên form đặt hàng. Ứng dụng kiểm tra dữ liệu thẻ trong bộ nhớ, mô phỏng gateway để sinh payment token và chỉ lưu token, brand, bốn số cuối cùng trạng thái giao dịch. PAN đầy đủ và CVV không được lưu vào database. Sau khi payment mock được approve, hệ thống tạo order; địa chỉ và số điện thoại của order được mã hóa trước khi ghi xuống MySQL."
    Add-Code "Checkout Form`n  -> Validate card in app memory`n  -> Generate pay_tok_xxx`n  -> Store paymentToken + cardLast4 + cardBrand`n  -> Encrypt order.address and order.phone`n  -> Save order and payment transaction"

    Add-Heading "4.6. Triển khai các cơ chế bảo mật trong ứng dụng" 2
    Add-Paragraph "Ở tầng ứng dụng, GoogleOAuthStartController và GoogleOAuthCallbackController xử lý OIDC. JwtUtils tạo và kiểm tra JWT cookie. FieldEncryptionUtils thực hiện AES-GCM, còn EncryptedStringConverter giúp JPA tự động mã hóa hoặc giải mã các trường nhạy cảm. PaymentTokenUtils và PaymentServiceImpl mô phỏng tokenization. Các thành phần này là phần hiện thực của kiến trúc bảo mật đã nêu ở trên, tức là chúng phục vụ các mục tiêu bảo mật cụ thể thay vì chỉ là các chức năng độc lập."

    Add-Heading "CHƯƠNG 5. THỰC NGHIỆM VÀ KẾT QUẢ" 1
    Add-Heading "5.1. Môi trường thực nghiệm" 2
    Add-Table @("Thành phần", "Công nghệ sử dụng") @(
        @("Hệ điều hành", "Windows"),
        @("Web server", "Apache HTTP Server"),
        @("App server", "Jetty Maven Plugin"),
        @("Backend", "Java Servlet/JSP"),
        @("Database", "MySQL"),
        @("Identity Provider", "Google OIDC"),
        @("Mã hóa", "AES-256-GCM"),
        @("Thanh toán", "Mock payment tokenization")
    )

    Add-Heading "5.2. Kết quả kiểm thử chức năng và bảo mật" 2
    Add-Paragraph "Hệ thống đã được kiểm thử theo chuỗi nghiệp vụ thực tế. Trước hết, dữ liệu mẫu gồm store, category, product và delivery được tạo trong MySQL. Sau khi đăng nhập, người dùng thêm sản phẩm vào giỏ hàng. Bảng cart và cart_item ghi nhận sản phẩm Test Product với số lượng tương ứng. Tiếp theo, người dùng checkout, nhập địa chỉ, số điện thoại, phương thức giao hàng và thông tin thẻ test 4111111111111111. Sau khi Place Order, hệ thống tạo payment transaction và order."
    Add-Table @("Kiểm thử", "Kết quả quan sát", "Đánh giá") @(
        @("Cart", "cart_item có product_id, product_name và count", "Sản phẩm được lưu trong database"),
        @("Payment", "paymentToken dạng pay_tok, cardLast4 = 1111, cardBrand = VISA", "Tokenization hoạt động"),
        @("PCI DSS", "panRetained = 0, cvvRetained = 0", "Không lưu PAN/CVV"),
        @("Order", "status = PROCESSED, isPaidBefore = 1", "Đơn hàng được xử lý thành công"),
        @("Field encryption", "address và phone dạng ENC:v1", "Dữ liệu nhạy cảm không lưu plaintext")
    )

    Add-Heading "5.3. Câu SQL kiểm chứng" 2
    Add-Paragraph "Các kết quả thực nghiệm được kiểm chứng trực tiếp trên MySQL bằng các câu truy vấn vào bảng cart_item, payment_transaction và orders. Cách kiểm chứng này phù hợp với prototype vì cho phép quan sát rõ dữ liệu được lưu sau mỗi bước nghiệp vụ."
    Add-Code "SELECT paymentToken, cardLast4, cardBrand, status, panRetained, cvvRetained FROM payment_transaction ORDER BY _id DESC;"
    Add-Code "SELECT _id, address, phone, status, isPaidBefore FROM orders ORDER BY _id DESC;"

    Add-Heading "CHƯƠNG 6. ĐÁNH GIÁ VÀ THẢO LUẬN" 1
    Add-Heading "6.1. Mức độ đáp ứng yêu cầu đề bài" 2
    Add-Table @("Yêu cầu", "Mức độ đáp ứng") @(
        @("OAuth2/OIDC, PKCE, JWT", "Đã triển khai Google OIDC Authorization Code + PKCE và JWT cookie"),
        @("Payment tokenization, PCI DSS constraints", "Đã mô phỏng tokenization và không lưu PAN/CVV"),
        @("Key management, TDE vs field-level encryption", "Đã triển khai field-level encryption và quản lý key qua env; chưa có KMS/HSM thật"),
        @("Rate limiting, API hardening", "Đã có rate limiting/OTP/lockout ở login; chưa có HMAC hoặc mTLS"),
        @("Latency, cost, security posture", "Đã phân tích định tính và xây dựng bảng đánh giá rủi ro")
    )

    Add-Heading "6.2. Phân tích trade-off" 2
    Add-Paragraph "Các cơ chế bảo mật được triển khai đều tạo ra một số chi phí nhất định. TLS làm tăng chi phí handshake ban đầu nhưng bảo vệ kênh truyền. Google OIDC có độ trễ cao hơn login nội bộ do cần redirect và verify ID token, nhưng giảm gánh nặng quản lý mật khẩu. AES-GCM làm tăng nhẹ chi phí CPU khi lưu hoặc đọc các trường nhạy cảm, tuy nhiên phạm vi mã hóa chỉ nằm ở address và phone nên overhead thấp hơn so với mã hóa toàn bộ dữ liệu ở tầng ứng dụng. Tokenization bổ sung bước validate và sinh token nhưng đổi lại hệ thống không lưu PAN/CVV, làm giảm đáng kể rủi ro khi database bị lộ."

    Add-Heading "6.3. Ước lượng chi phí triển khai" 2
    Add-Paragraph "Trong prototype, chi phí gần như bằng 0 vì hệ thống dùng môi trường local, chứng chỉ ZeroSSL và mock payment gateway. Nếu triển khai production, chi phí sẽ tăng khi sử dụng Cloud KMS, HSM, payment gateway sandbox/production, monitoring và hạ tầng vận hành. Để giảm chi phí KMS và độ trễ, hệ thống nên dùng envelope encryption, trong đó KMS chỉ bảo vệ master key hoặc data key đã wrap, còn dữ liệu ứng dụng được mã hóa bằng data key được quản lý và cache ngắn hạn trong bộ nhớ an toàn."

    Add-Heading "6.4. Security posture" 2
    Add-Table @("Rủi ro còn lại", "Tình trạng hiện tại", "Hướng cải tiến") @(
        @("XSS", "Cookie HttpOnly giúp giảm rủi ro lấy JWT", "Bổ sung CSP và sanitize input"),
        @("CSRF", "SameSite=Lax giảm rủi ro cơ bản", "Bổ sung CSRF token cho form quan trọng"),
        @("Lộ key env", "Key không hard-code trong source", "Chuyển sang Vault hoặc KMS"),
        @("Payment replay", "Có trạng thái order cơ bản", "Bổ sung idempotency key"),
        @("API nội bộ", "Chưa có service-to-service auth", "Áp dụng HMAC hoặc mTLS khi tách microservices")
    )

    Add-Heading "CHƯƠNG 7. HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN" 1
    Add-Paragraph "Prototype hiện tại chưa triển khai microservices đúng nghĩa, chưa có Kubernetes, API Gateway, Vault, KMS, HSM hoặc mTLS. Payment gateway cũng mới dừng ở mức mock thay vì tích hợp Stripe hoặc Braintree sandbox. Ngoài ra, hệ thống chưa có fraud scoring, chưa benchmark p95/p99 latency và một số dữ liệu demo vẫn được tạo thủ công trong MySQL. Những hạn chế này là phù hợp với phạm vi đồ án môn học nhưng cần được ghi nhận rõ để tránh nhầm lẫn với một hệ thống production."
    Add-Paragraph "Trong tương lai, hệ thống có thể được mở rộng theo hướng tách catalog, cart, order và payment thành các service riêng; thêm API Gateway để validate JWT và rate limit; tích hợp Vault hoặc Cloud KMS cho key management; áp dụng envelope encryption; thêm idempotency key cho payment request; tích hợp payment sandbox thật; bổ sung CSRF token, CSP header và công cụ kiểm thử như OWASP ZAP."

    Add-Heading "CHƯƠNG 8. KẾT LUẬN" 1
    Add-Paragraph "Đề tài đã xây dựng được một prototype thương mại điện tử có tích hợp nhiều cơ chế mật mã và bảo mật quan trọng trong thực tế. Hệ thống sử dụng TLS với chứng chỉ ZeroSSL để bảo vệ kênh truyền, Google OpenID Connect Authorization Code Flow kết hợp PKCE để tăng cường bảo mật xác thực, JWT cookie an toàn để quản lý phiên, AES-256-GCM để mã hóa dữ liệu nhạy cảm và tokenization để mô phỏng thanh toán không lưu PAN/CVV."
    Add-Paragraph "Kết quả thực nghiệm cho thấy dữ liệu địa chỉ và số điện thoại trong bảng orders được lưu dưới dạng ENC:v1, còn bảng payment_transaction chỉ lưu payment token, bốn số cuối và brand thẻ. Hai cờ panRetained và cvvRetained đều bằng 0, thể hiện định hướng xử lý dữ liệu thẻ an toàn theo tinh thần PCI DSS. Mặc dù hệ thống chưa triển khai đầy đủ các thành phần production như KMS/HSM, Vault hoặc microservices, prototype đã minh họa được các nguyên tắc cốt lõi trong thiết kế bảo mật cho nền tảng thương mại điện tử."

    Add-Heading "PHỤ LỤC. DANH SÁCH MINH CHỨNG ĐỀ XUẤT" 1
    Add-Table @("STT", "Minh chứng nên chèn vào báo cáo") @(
        @("1", "Ảnh chứng chỉ TLS ZeroSSL của uteshop.kesug.com"),
        @("2", "Ảnh đăng nhập Google thành công"),
        @("3", "Ảnh cookie JWT có HttpOnly, Secure và SameSite"),
        @("4", "Ảnh bảng cart_item có sản phẩm trong giỏ"),
        @("5", "Ảnh màn hình checkout nhập card test"),
        @("6", "Ảnh bảng payment_transaction có pay_tok, cardLast4, panRetained = 0 và cvvRetained = 0"),
        @("7", "Ảnh bảng orders có address và phone dạng ENC:v1"),
        @("8", "Ảnh code FieldEncryptionUtils hoặc Google OIDC callback")
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
