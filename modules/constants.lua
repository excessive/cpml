-- @module constants

local constants = {}

-- same as C's FLT_EPSILON
constants.FLT_EPSILON = 1.19209290e-07

-- same as C's DBL_EPSILON
constants.DBL_EPSILON = 2.2204460492503131e-16

-- used for quaternion.slerp
constants.DOT_THRESHOLD = 0.9995

return constants
