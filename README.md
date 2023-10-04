# NES Emulator

dart实现的NES模拟器
参考[StepFC](https://github.com/dustpg/StepFC)

## 目标

- [x] ROM
  - [x] 基础信息读取
  - [x] PRG-ROM
  - [x] CHR-ROM
- [ ] Mapper
  - [x] 内存以及读写
  - [ ] Mapper000
- [ ] CPU
  - [x] 寄存器
  - [x] 寻址模式
  - [x] 指令执行环境
  - [x] 指令具体实现细节
  - [x] NMI中断
  - [x] RESET
  - [ ] 跳转跨页的指令周期变化
- [ ] PPU
  - [x] VBlank
  - [ ] 寄存器
  - [x] 背景渲染
  - [ ] Sprite
  - [ ] 名称表
  - [ ] 属性表
  - [ ] 调色盘
  - [ ] 调色盘索引
  - [ ] 镜像
- [ ] 输入
  - [ ] 未实现
- [ ] APU
  - [ ] 未实现
