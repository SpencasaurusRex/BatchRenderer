package data


Game_Data :: struct {
    entities: [dynamic]Entity,
}


Vec3 :: [3]f32


Entity :: struct {
    pos: Vec3,
    rot: f32,
    transform: matrix[4, 4]f32,
}