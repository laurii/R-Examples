# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

context('wait')

source('utilities.R')

wait <- RPresto:::wait

test_that('wait works', {
  expect_gt(system.time(wait())['elapsed'], 50/1000)
})

