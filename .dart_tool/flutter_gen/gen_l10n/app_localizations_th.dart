import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'ชีวิตที่เหลืออยู่';

  @override
  String get startButton => 'เริ่มต้น';

  @override
  String get aboutUsButton => 'เกี่ยวกับเรา';

  @override
  String get supportButton => 'สนับสนุน';

  @override
  String get description => 'โปรแกรมที่กระตุ้นให้เราตระหนักว่าเรามีเวลาในชีวิตจำกัดและควรเร่งทำสิ่งสำคัญก่อนเวลาจะหมดลง';

  @override
  String get languageEnglish => 'ภาษาอังกฤษ';

  @override
  String get languageThai => 'ภาษาไทย';

  @override
  String get appBarTitle => 'กลับ';

  @override
  String get selectDateHeader => 'เลือกวันที่';

  @override
  String get selectDateSubHeader => 'คุณเกิดเมื่อไหร่?';

  @override
  String get yearLabel => 'ปี';

  @override
  String get monthLabel => 'เดือน';

  @override
  String get dayLabel => 'วัน';

  @override
  String get nextButton => 'ถัดไป';

  @override
  String snackBarMessage(Object date) {
    return 'วันที่ที่เลือก: $date';
  }

  @override
  String get january => 'มกราคม';

  @override
  String get february => 'กุมภาพันธ์';

  @override
  String get march => 'มีนาคม';

  @override
  String get april => 'เมษายน';

  @override
  String get may => 'พฤษภาคม';

  @override
  String get june => 'มิถุนายน';

  @override
  String get july => 'กรกฎาคม';

  @override
  String get august => 'สิงหาคม';

  @override
  String get september => 'กันยายน';

  @override
  String get october => 'ตุลาคม';

  @override
  String get november => 'พฤศจิกายน';

  @override
  String get december => 'ธันวาคม';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get nextStepDescription => 'ต่อไปเว็บไซต์จะสอบถาม วัน-เดือน-ปี ที่คุณคาดว่าน่าจะเป็นเวลาตายของคุณ เพื่อประมาณเวลาที่เหลืออยู่บนโลกใบนี้.';

  @override
  String get disclaimer => 'โปรแกรมนี้ไม่ใช่โปรแกรมพยากรณ์ ดังนั้นเวลาในชีวิตของคุณอาจหมดลงก่อนหรือหลังจากนี้ก็ได้';

  @override
  String get next => 'ถัดไป';

  @override
  String get readyToStartCountdown => 'หากคุณพร้อมแล้ว เรามาเริ่มนับเวลาถอยหลังชีวิตได้เลย';

  @override
  String get confirm => 'ยืนยันข้อมูล';

  @override
  String get selectAll => 'กรุณาเลือกรายการให้ครบ';

  @override
  String get agree => 'ตกลง';

  @override
  String get pleaseSelectMonth => 'กรุณาเลือกเดือนก่อน';

  @override
  String get deathYear => 'ปีตาย';

  @override
  String get deathYearQuestion => 'คุณคิดว่าคุณจะตายปีใด?';

  @override
  String get yearLabel_lv1 => 'พ.ศ.';

  @override
  String ageWithYear(Object ageInThatYear) {
    return 'อายุ $ageInThatYear ปี';
  }

  @override
  String get deathMonthTitle => 'เดือนตาย';

  @override
  String get deathMonthQuestion => 'คุณคิดว่าคุณจะตายเดือนใด?';

  @override
  String get deathDayTitle => 'วันตาย';

  @override
  String get deathDayQuestion => 'คุณคิดว่าคุณจะตายวันใด?';

  @override
  String get sunday => 'อา';

  @override
  String get monday => 'จ';

  @override
  String get tuesday => 'อ';

  @override
  String get wednesday => 'พ';

  @override
  String get thursday => 'พฤ';

  @override
  String get friday => 'ศ';

  @override
  String get saturday => 'ส';

  @override
  String get deathTimeTitle => 'เวลาตาย';

  @override
  String get deathTimeQuestion => 'คุณคิดว่าคุณจะตายเวลาใด?';

  @override
  String get midnight => 'เที่ยงคืน';

  @override
  String get threeAM => 'ตี 3';

  @override
  String get sixAM => '6 โมงเช้า';

  @override
  String get nineAM => '9 โมงเช้า';

  @override
  String get noon => 'เที่ยงวัน';

  @override
  String get threePM => 'บ่าย 3';

  @override
  String get sixPM => '6 โมงเย็น';

  @override
  String get ninePM => '3 ทุ่ม';

  @override
  String get customTime => 'กำหนดเวลาเอง';

  @override
  String get customTimeDialogTitle => 'กำหนดเวลาเอง';

  @override
  String get customTimeDialogHint => 'กรุณาป้อนเวลาในรูปแบบ 24 ชั่วโมง (HH:MM)';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get invalidTimeFormat => 'รูปแบบเวลาไม่ถูกต้อง';

  @override
  String get deathDateTimeMessage => 'คุณกำหนดวัน-เวลาตาย ไว้ที่';

  @override
  String get calculateButtonMessage => 'กรุณากดปุ่มคำนวณก่อน';

  @override
  String get timeLabel => 'เวลา';

  @override
  String get nextStepMessage => 'หน้าถัดไป คือประมาณเวลาชีวิตที่คุณมีเหลืออยู่';

  @override
  String get breatheAndPressMessage => 'หายใจเข้าลึกๆ แล้วกดดูผลลัพธ์';

  @override
  String get viewResults => 'ดูผลลัพธ์';

  @override
  String get appTitle_1 => 'ชีวิตนับถอยหลัง';

  @override
  String get timeRemainingTitle => 'คุณเหลือเวลาอีก';

  @override
  String get timeElapsedTitle => 'ผ่านไปแล้ว';

  @override
  String get birthTitle => 'เกิด';

  @override
  String get deathTitle => 'ตาย';

  @override
  String get saveImage => 'บันทึกรูป';

  @override
  String get resetButton => 'เริ่มใหม่';

  @override
  String get dayLabel_1 => 'วัน';

  @override
  String get hourLabel => 'ชั่วโมง';

  @override
  String get minuteLabel => 'นาที';

  @override
  String get secondLabel => 'วินาที';

  @override
  String get saveImageButtonLabel => 'บันทึกรูป';

  @override
  String get closeButtonLabel => 'ปิด';

  @override
  String get shareTitle => 'แชร์';

  @override
  String get created_by => 'จัดทำโดย';

  @override
  String get sponsored_by => 'สนับสนุนโดย';
}
