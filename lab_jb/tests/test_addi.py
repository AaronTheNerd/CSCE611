# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels

import test_util

test_util.run_test("""
addi x1, x0, 12
""", {1: 12})