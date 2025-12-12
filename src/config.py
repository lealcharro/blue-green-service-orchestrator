from dotenv import load_dotenv
import os

load_dotenv()

VERSION = os.getenv("VERSION", "1.0.0")
