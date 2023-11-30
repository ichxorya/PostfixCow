[[Ứng dụng trực quan hóa thuật toán liên quan đến ký pháp hậu tố Ba Lan -- PostfixCow.exe]]

- Vài nét về cách triển khai bài tập lớn:
+ Bài tập lớn được triển khai dựa trên nền tảng công cụ phát triển game Godot 4.
+ Ứng dụng được xây dựng gồm 2 chức năng chính: 
	#1 Chuyển đổi biểu thức toán học trung tố sang dạng hậu tố (ký pháp Hậu tố Ba Lan).
	#2 Tính giá trị của biểu thức toán học hậu tố.
+ Các ký tự được cho phép nhập vào: Dấu cách, Số nguyên, các toán tử (+, -, *, /) và các dấu ngoặc ( ).
+ Ghi chú: Đầu ra của #2 là một số nguyên, do đó phép chia có thể gặp vấn đề.

+ Về cơ bản, chương trình được tổ chức như sau:
	Chọn chế độ #1 hoặc #2; chỉnh tốc độ nếu cần
	Nhập biểu thức hợp lệ và bấm nút
	Chờ minh họa thuật toán
	Nhận được kết quả (và có thể nhấn nút để sao chép).

- Cách cài đặt, thực thi bài tập lớn:
+ Cài đặt: 
	Sử dụng công cụ Godot 4 nạp file project.godot
	Chạy bằng cách ấn nút "play" để chạy thử
	Để xuất chương trình, nhấn vào phần Project->Export và chọn Add để thêm nền tảng cần xuất chương trình (config nếu cần); rồi nhấn Export All, chọn Release.

	Trên nền tảng Windows: Có thể chạy ngay "PostfixCow.exe".
	
+ Cách thực thi/sử dụng bài tập lớn:
	Chế độ mặc định sẽ là #1. Để đổi chế độ, nhấn vào hình con bò.
	Âm thanh và nhạc được bật mặc định, để bật/tắt hãy nhấn vào hình cái loa. Khi âm thanh đã tắt, con bò sẽ ngừng nhảy múa.
	Có thể tăng hoặc giảm tốc độ nếu muốn, nhưng phải thực hiện khi không chạy thuật toán.
	
	Nhập biểu thức toán học phù hợp vào thanh nội dung rồi nhấn nút để bắt đầu minh họa thuật toán.
	Khi thuật toán trả về kết quả có thể nhấn nút Copy để sao chép.

- Nguồn tham khảo chính:
+ docs.godotengine.org - Tài liệu Godot
+ mycodeschool và Geeksforgeeks - Tài liệu về 2 thuật toán biểu diễn trong chương trình.
	https://gist.github.com/mycodeschool/7867739
	https://m.youtube.com/watch?v=vq-nUF0G4fI&pp=ygULI3VzaW5nc3RhY2s%3D
	https://www.geeksforgeeks.org/convert-infix-prefix-notation/
	https://www.geeksforgeeks.org/evaluate-the-value-of-an-arithmetic-expression-in-reverse-polish-notation-in-java/

- Các thành phần minh họa (được sử dụng vì mục đích giáo dục phi lợi nhuận):
+ Nhạc nền: Cypis - Gdzie jest biały węgorz ? (Zejście) [8-bit Cover] - https://www.youtube.com/watch?v=EWdfDV37xdE&pp=ygULZ2R6aWUgbW9vcGg%3D
+ Hiệu ứng bò kêu: https://www.101soundboards.com/boards/10143-cow-sounds
+ Con bò nhảy múa: Tenor "Polish Cow"
	
- Một số lỗi vẫn còn tồn đọng (VD: Từ đầu vào sai vẫn sinh ra biểu thức, tốc độ không thể chỉnh trong lúc thực thi, lỗi hiển thị do await chưa được dùng tốt...)