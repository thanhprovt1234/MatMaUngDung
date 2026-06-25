# UTESHOP

Do an web thuong mai dien tu xay dung theo mo hinh Java Web MVC, ho tro dang ky, dang nhap, quan ly tai khoan, gio hang, dat hang, danh gia san pham va khu vuc quan tri.

## Cong nghe chinh

- Backend: Java 22, Jakarta Servlet, JSP, JSTL
- ORM / Persistence: Hibernate ORM, JPA
- Database: MySQL
- Build tool: Maven
- Dong goi: file WAR de deploy len server ung dung ben ngoai
- Frontend: JSP, Bootstrap, HTML/CSS/JavaScript
- Bao mat / ho tro: BCrypt, Hibernate Validator, SiteMesh

## Thu vien / dependency noi bat

- `jakarta.servlet-api`
- `jakarta.servlet.jsp-api`
- `jakarta.servlet.jsp.jstl-api`
- `hibernate-core`
- `hibernate-validator`
- `mysql-connector-java`
- `sitemesh`
- `commons-io`
- `javax.mail`
- `jbcrypt`
- `lombok`

## Cau truc tong quan

- `src/main/java`: controller, service, dao, entity, config
- `src/main/webapp`: JSP views, assets, cau hinh web
- `src/main/resources/META-INF/persistence.xml`: cau hinh ket noi MySQL
- `scripts/`: script build file WAR

## Cau hinh database

Project su dung MySQL, thong tin ket noi nam trong:

- `src/main/resources/META-INF/persistence.xml`

Mac dinh:

- Database: `projectfinal`
- Host: `localhost:3306`
- User: `root`
- Password: cap nhat theo may cua ban trong `persistence.xml`

## Build project thanh file WAR

Chay lenh sau de build project:

```powershell
mvn clean package
```

Hoac dung script:

```powershell
.\scripts\build-war.ps1
```

File WAR sau khi build:

- `target/uteshop.war`

Deploy file `target/uteshop.war` len server ung dung ho tro Jakarta Servlet/JSP.
Context mac dinh se la `/uteshop`, URL trang chu thuong la `/uteshop/home`.

## Chay local bang Jetty

Tao keystore HTTPS local lan dau:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\create-local-keystore.ps1
```

Chay lenh:

```powershell
mvn jetty:run
```

URL mac dinh:

- `http://localhost:8081/uteshop/home`
- `https://localhost:8443/uteshop/home`

Neu port mac dinh dang bi chiem, co the doi port khi chay:

```powershell
mvn "-Djetty.http.port=18080" "-Djetty.https.port=18443" jetty:run
```

## Cau hinh SMTP OTP

Chuc nang dang nhap va quen mat khau su dung OTP gui qua SMTP. Truoc khi chay app, cau hinh SMTP trong PowerShell:

```powershell
$env:SMTP_HOST="smtp.gmail.com"
$env:SMTP_PORT="587"
$env:SMTP_USERNAME="your-email@gmail.com"
$env:SMTP_PASSWORD="your-gmail-app-password"
$env:SMTP_FROM="your-email@gmail.com"
$env:SMTP_FROM_NAME="UTESHOP Security"
$env:SMTP_STARTTLS="true"
mvn jetty:run
```

Neu dung Gmail, hay tao App Password trong Google Account va dung gia tri do cho `SMTP_PASSWORD`; khong dung mat khau dang nhap Gmail thong thuong.

Co the cau hinh bang JVM property neu khong muon dung bien moi truong:

```powershell
mvn "-Dsmtp.username=your-email@gmail.com" "-Dsmtp.password=your-gmail-app-password" "-Dsmtp.from=your-email@gmail.com" jetty:run
```

Luong OTP:

- Login dung email/password xong se yeu cau OTP tai `/uteshop/login`.
- Forgot password gui OTP tai `/uteshop/forgot-password`, xac thuc OTP roi moi cho dat mat khau moi.
- OTP co hieu luc 5 phut.

## Cau hinh JWT

Sau khi dang nhap va xac thuc OTP thanh cong, app tao JWT access token trong cookie `ACCESS_TOKEN`.
Token co hieu luc 2 tieng, trung voi session timeout hien tai.

Nen cau hinh secret rieng truoc khi chay production/local nghiem tuc:

```powershell
$env:JWT_SECRET="doi-chuoi-nay-thanh-bi-mat-it-nhat-32-ky-tu"
mvn jetty:run
```

Neu khong cau hinh `JWT_SECRET`, app dung secret mac dinh chi phu hop de test local.

JWT co the duoc doc tu:

- Cookie `ACCESS_TOKEN`
- Header `Authorization: Bearer <token>`

## Tai khoan test

### Project da fix

#### ROLE ADMIN

- Email: `hotunglam26062@gmail.com`
- Password: `Abcd@123`

#### ROLE USER

- Email: `hotunglam266@gmail.com`
- Password: `Lam@1234`

### Project chua fix

#### ROLE ADMIN

- Email: `thuadmin@gmail.com`
- Password: `A@123456`

#### ROLE USER

- Email: `thuuser@gmail.com`
- Password: `A@123456`

## Ghi chu

- Project dong goi dang `war`
- Maven chi build file WAR, khong tu dong tai hoac khoi dong Tomcat
