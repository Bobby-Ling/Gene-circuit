import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, current_dir)

msg = 'Hello from %s'%(os.path.abspath(__file__))
msg += "\n"

for path in sys.path:
    msg += f"> {path}\n"

print(msg)

def get_path(relative_path):
    try:
        base_path = sys._MEIPASS # pyinstaller打包后的路径
    except AttributeError:
        base_path = os.path.abspath(".") # 当前工作目录的路径
 
    return os.path.normpath(os.path.join(base_path, relative_path)) # 返回实际路径

os.chdir(get_path("."))

from main import main
main()