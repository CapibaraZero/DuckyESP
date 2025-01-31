# This file is part of the Capibara zero (https://github.com/CapibaraZero/fw or https://capibarazero.github.io/).
# Copyright (c) 2024 Andrea Canale.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import os
Import("env")

try:
    if env.GetProjectOption("board_has_otg") == "true":
        os.system("make clean && make")
except:
    print("Missing board_has_otg flag")
