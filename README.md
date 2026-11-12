# ZIIQ · KAITAN Base UI

Roblox client UI แบบดำ ขาว เทา กรอบเหลี่ยม ฟอนต์ GothamBold พร้อมโลโก้และชื่อผู้เล่นจริง
ช่องเรียงชิดซ้าย เคลื่อนไหวเมื่อเพิ่ม/ลบ และย่อให้เห็นทั้งหมดโดยไม่มีแถบเลื่อน

## เริ่มใช้งานใน Roblox Studio

1. สร้าง ModuleScript ชื่อ `KaitanBase` ใน `ReplicatedStorage` แล้วใส่โค้ดจาก `KaitanBase.lua`
2. สร้าง LocalScript ใน `StarterPlayerScripts` ใช้โค้ดด้านล่างหรือ `example.client.lua`
3. กด Play ใช้ Right Ctrl หรือปุ่ม HUD เพื่อซ่อน/แสดง

```lua
local Base = require(game:GetService("ReplicatedStorage"):WaitForChild("KaitanBase"))
local ui = Base.new({
    Title = "ZIIQ · KAITAN",
    Logo = "134013054250379",
})
ui:AddStat("Money", "BALANCE", 1000)
ui:AddDetail("Status", "STATUS", "Running")
ui:Update("Money", 1500)
ui:Remove("Status")
```

## ตั้งค่า Base.new(options)

| Option | ค่าเริ่มต้น | ความหมาย |
| --- | --- | --- |
| Title | ZIIQ · KAITAN | ชื่อแบรนด์ |
| Logo | 134013054250379 | Asset ID หรือ image URI |
| Username | LocalPlayer.DisplayName | ชื่อหลัก ไม่มี @ |
| Name | ZIIQKaitanBase | ชื่อ ScreenGui; สร้างชื่อเดิมจะปิดตัวเก่าก่อน |
| ToggleKey | Enum.KeyCode.RightControl | ปุ่มซ่อน/แสดง |
| ShowToggle | true | แสดงปุ่ม HUD สำหรับเมาส์/สัมผัส |
| StatHeading | OVERVIEW | หัวข้อสถิติ |
| DetailHeading | SESSION DETAILS | หัวข้อรายละเอียด |

## API

| Method | ใช้งาน |
| --- | --- |
| ui:AddStat(id, title, value) | เพิ่มช่องสถิติตัวเลขใหญ่ |
| ui:AddDetail(id, title, value) | เพิ่มช่องรายละเอียด |
| ui:Update(id, value) | เปลี่ยนค่า |
| ui:Remove(id) | ลบช่องและจัดแถวใหม่ |
| ui:Clear() | ลบทุกช่อง คงหัว UI |
| ui:SetUsername(name) | เปลี่ยนชื่อที่แสดง |
| ui:SetVisible(boolean) | กำหนดการแสดงผล |
| ui:Toggle() | สลับซ่อน/แสดง |
| ui:Destroy() | ลบ UI และตัด event connections ภายใน |
| ui.Gui | ScreenGui สำหรับผูก cleanup ของโค้ดคุณ |

ID ต้องเป็น string ไม่ว่าง เพิ่ม ID เดิมจะอัปเดตช่องเดิม ค่ารองรับข้อความ/ตัวเลข
ไม่มีจำนวนช่องสูงสุดที่กำหนด แต่เมื่อช่องเยอะ ขนาดตัวหนังสือจะลดลงตามพื้นที่
Library เริ่มต้นไม่มีช่อง และไม่อ่าน/เขียนข้อมูลเกมเอง จึงไม่ทับค่าที่ส่งผ่าน Update
Session timer ทำงานอัตโนมัติ เริ่มใหม่เมื่อสร้าง UI

## อัปโหลด GitHub

อัปโหลดไฟล์ในโฟลเดอร์นี้ไป repository ของคุณ: `KaitanBase.lua`, `example.client.lua`, `README.md`, `.gitignore`
ใช้ GitHub เก็บและแจกจ่าย source แล้วนำ module เข้าเกมผ่าน Studio หรือ workflow ของคุณ
LocalScript มาตรฐานใช้ `require(ModuleScript)` ตามตัวอย่าง ไม่โหลด raw GitHub URL ด้วย require
ยังไม่มี LICENSE ที่อนุญาตเผยแพร่ซ้ำ เลือก license ที่ต้องการก่อนเปิดให้ผู้อื่นนำโค้ดไปใช้
โลโก้เป็น asset แยกและต้องเข้าถึงได้ใน experience ที่ใช้งาน
