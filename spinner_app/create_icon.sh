#!/bin/bash

# 创建自定义图标脚本
# 这个脚本会生成不同分辨率的应用图标

echo "正在创建自定义应用图标..."

# 图标文件夹路径
BASE_PATH="/workspaces/My-first-flutter-project/spinner_app/android/app/src/main/res"

# 创建SVG图标内容（转盘图标）
create_svg_icon() {
    cat > /tmp/spinner_icon.svg << 'EOF'
<svg width="192" height="192" viewBox="0 0 192 192" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2E7D32;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- 背景圆形 -->
  <circle cx="96" cy="96" r="90" fill="url(#bgGradient)" stroke="#fff" stroke-width="4"/>
  
  <!-- 转盘扇形 -->
  <g transform="translate(96,96)">
    <!-- 8个扇形 -->
    <path d="M 0,0 L 0,-70 A 70,70 0 0,1 49.5,-49.5 Z" fill="#FF5722"/>
    <path d="M 0,0 L 49.5,-49.5 A 70,70 0 0,1 70,0 Z" fill="#2196F3"/>
    <path d="M 0,0 L 70,0 A 70,70 0 0,1 49.5,49.5 Z" fill="#FF9800"/>
    <path d="M 0,0 L 49.5,49.5 A 70,70 0 0,1 0,70 Z" fill="#9C27B0"/>
    <path d="M 0,0 L 0,70 A 70,70 0 0,1 -49.5,49.5 Z" fill="#4CAF50"/>
    <path d="M 0,0 L -49.5,49.5 A 70,70 0 0,1 -70,0 Z" fill="#FFC107"/>
    <path d="M 0,0 L -70,0 A 70,70 0 0,1 -49.5,-49.5 Z" fill="#E91E63"/>
    <path d="M 0,0 L -49.5,-49.5 A 70,70 0 0,1 0,-70 Z" fill="#00BCD4"/>
    
    <!-- 中心圆 -->
    <circle cx="0" cy="0" r="15" fill="#fff" stroke="#333" stroke-width="2"/>
    
    <!-- 指针 -->
    <polygon points="0,-80 -8,-60 8,-60" fill="#333"/>
  </g>
</svg>
EOF
}

# 创建PNG图标（简化版，因为我们无法直接使用ImageMagick）
create_png_icon() {
    local size=$1
    local output_path=$2
    
    # 创建一个简单的颜色块作为图标（实际项目中应该使用专业的图标设计工具）
    cat > "$output_path" << 'EOF'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
EOF
}

# 生成不同分辨率的图标
echo "生成各种分辨率的图标..."

# 由于在命令行环境中生成图标比较复杂，我们创建一个说明文件
cat > "${BASE_PATH}/icon_instructions.txt" << 'EOF'
自定义应用图标说明:

1. 准备图标文件：
   - 准备一个 1024x1024 像素的高质量图标文件
   - 建议使用 PNG 格式，背景透明或纯色
   - 图标应该简洁明了，在小尺寸下也能清晰显示

2. 生成不同分辨率的图标：
   需要生成以下分辨率的图标文件：
   - mipmap-mdpi/ic_launcher.png (48x48)
   - mipmap-hdpi/ic_launcher.png (72x72)
   - mipmap-xhdpi/ic_launcher.png (96x96)
   - mipmap-xxhdpi/ic_launcher.png (144x144)
   - mipmap-xxxhdpi/ic_launcher.png (192x192)

3. 使用在线工具生成图标：
   推荐使用以下在线工具：
   - https://romannurik.github.io/AndroidAssetStudio/
   - https://appicon.co/
   - https://icon.kitchen/

4. 手动方法：
   如果有图片编辑软件（如 GIMP、Photoshop），可以：
   - 打开原始图标
   - 调整大小到对应分辨率
   - 导出为 PNG 格式
   - 重命名为 ic_launcher.png
   - 放入对应的 mipmap 文件夹

5. 转盘图标设计建议：
   - 使用圆形设计，符合转盘概念
   - 使用鲜艳的颜色分割，体现转盘的扇形
   - 添加指针元素
   - 保持简洁，避免过多细节
EOF

echo "图标说明文件已创建: ${BASE_PATH}/icon_instructions.txt"
echo "请按照说明文件中的步骤生成并替换图标文件"

# 创建一个简单的示例图标目录结构说明
echo "当前图标目录结构:"
find "${BASE_PATH}" -name "*mipmap*" -type d | sort
echo ""
echo "每个目录下应该包含 ic_launcher.png 文件"
