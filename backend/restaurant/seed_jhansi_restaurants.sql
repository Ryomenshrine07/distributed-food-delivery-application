-- ============================================================================
-- Seed: real restaurants in Jhansi, Uttar Pradesh with accurate coordinates.
-- Restaurant names + neighborhoods + lat/lng are real Jhansi data.
-- Menu items are representative dishes with realistic INR prices.
-- Run:  psql -U ryomen07 -d restaurant_db -f backend/restaurant/seed_jhansi_restaurants.sql
-- ============================================================================

DO $$
DECLARE
    rid   uuid;
    owner uuid;
    cat   uuid;
    cat2  uuid;
BEGIN
    ------------------------------------------------------------------
    -- 1. UP93 Restro and Lounge  (Sadar Bazar, Kachahri Road, Civil Lines)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'UP93 Restro and Lounge',
         'Multi-cuisine rooftop dining and lounge in Civil Lines.',
         '+91 9100093093', '419, Sadar Bazar, Kachahri Road, Civil Lines', 'Jhansi',
         25.4566, 78.5792, true, 35, 4.3, 'North Indian',
         TIME '11:00', TIME '23:00', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Starters', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Paneer Tikka',     'Char-grilled cottage cheese with spices',     260.00, true, true,  cat, now(), now()),
        (gen_random_uuid(), 'Chicken Tikka',    'Tandoori marinated chicken chunks',           320.00, true, false, cat, now(), now()),
        (gen_random_uuid(), 'Veg Spring Roll',  'Crispy rolls stuffed with vegetables',        180.00, true, true,  cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'Main Course', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Butter Chicken',        'Creamy tomato gravy with tandoori chicken', 380.00, true, false, cat2, now(), now()),
        (gen_random_uuid(), 'Dal Makhani',           'Slow-cooked black lentils in butter',       240.00, true, true,  cat2, now(), now()),
        (gen_random_uuid(), 'Paneer Butter Masala',  'Cottage cheese in rich makhani gravy',      300.00, true, true,  cat2, now(), now()),
        (gen_random_uuid(), 'Butter Naan',           'Soft tandoori bread brushed with butter',    50.00, true, true,  cat2, now(), now());

    ------------------------------------------------------------------
    -- 2. Pizza Hut  (Om Complex, Shivpuri Road, Civil Lines)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'Pizza Hut',
         'World famous pan pizzas, sides and desserts.',
         '+91 9120120120', '943, Om Complex, Shivpuri Road, Civil Lines', 'Jhansi',
         25.4538, 78.5760, true, 30, 4.1, 'Italian',
         TIME '11:00', TIME '23:00', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Pizzas', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Margherita Pizza',        'Classic cheese and tomato pizza',            199.00, true, true,  cat, now(), now()),
        (gen_random_uuid(), 'Veggie Supreme Pizza',    'Loaded with garden vegetables',              399.00, true, true,  cat, now(), now()),
        (gen_random_uuid(), 'Chicken Supreme Pizza',   'Topped with grilled chicken and peppers',    499.00, true, false, cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'Sides and Desserts', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Garlic Bread',     'Baked bread sticks with garlic butter', 149.00, true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Choco Lava Cake',  'Warm chocolate cake with molten centre',109.00, true, true, cat2, now(), now());

    ------------------------------------------------------------------
    -- 3. City Spicee  (Damru Complex, Elite Sipri Road, Civil Lines)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'City Spicee',
         'Pure vegetarian North Indian family restaurant near Elite Crossing.',
         '+91 9151151151', 'Shop 1852, Damru Complex, Elite Sipri Road, Civil Lines', 'Jhansi',
         25.4502, 78.5828, true, 40, 4.2, 'North Indian',
         TIME '11:30', TIME '23:00', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Veg Main Course', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Shahi Paneer',  'Cottage cheese in cashew tomato gravy', 260.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Veg Kofta',     'Vegetable dumplings in creamy curry',   240.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Mix Veg',       'Seasonal vegetables in onion gravy',    220.00, true, true, cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'Breads and Rice', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Tandoori Roti', 'Whole wheat bread from the tandoor', 25.00,  true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Veg Biryani',   'Fragrant rice with vegetables',      220.00, true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Jeera Rice',    'Basmati rice tempered with cumin',   140.00, true, true, cat2, now(), now());

    ------------------------------------------------------------------
    -- 4. The Indian Spice Cafe and Restaurant  (Jhansi Road, Sipri Bazaar)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'The Indian Spice Cafe and Restaurant',
         'Indian, Chinese and cafe favourites in Sipri Bazaar.',
         '+91 9161161161', 'Jhansi Road, Sipri Bazaar', 'Jhansi',
         25.4372, 78.5980, true, 35, 4.0, 'Chinese',
         TIME '10:30', TIME '23:00', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Chinese', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Veg Hakka Noodles',   'Wok-tossed noodles with vegetables', 160.00, true, true,  cat, now(), now()),
        (gen_random_uuid(), 'Chilli Paneer',       'Crispy paneer in spicy sauce',       220.00, true, true,  cat, now(), now()),
        (gen_random_uuid(), 'Chicken Manchurian',  'Chicken balls in Manchurian gravy',  260.00, true, false, cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'Snacks and Beverages', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Samosa',      'Two crisp potato-stuffed pastries', 30.00,  true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Veg Burger',  'Spiced veg patty with fresh veggies',120.00, true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Cold Coffee', 'Chilled blended coffee with cream',  110.00, true, true, cat2, now(), now());

    ------------------------------------------------------------------
    -- 5. Vrindavan Restaurant  (Near Sipri Bazar Petrol Pump, Sipri Bazaar)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'Vrindavan Restaurant',
         'Pure vegetarian thali, chaat and South Indian.',
         '+91 9171171171', 'Near Sipri Bazar Petrol Pump, Sipri Bazaar', 'Jhansi',
         25.4348, 78.6015, true, 30, 4.4, 'Pure Veg',
         TIME '10:30', TIME '22:00', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Thali and Main', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Special Veg Thali', 'Assorted curries, dal, rice, roti, sweet', 220.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Chole Bhature',     'Spiced chickpeas with fried bread',        130.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Rajma Chawal',      'Kidney beans curry with steamed rice',     150.00, true, true, cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'South Indian', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Masala Dosa', 'Crisp dosa with spiced potato filling', 120.00, true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Idli Sambar', 'Steamed rice cakes with sambar',         90.00, true, true, cat2, now(), now()),
        (gen_random_uuid(), 'Paneer Dosa', 'Dosa stuffed with paneer masala',       150.00, true, true, cat2, now(), now());

    ------------------------------------------------------------------
    -- 6. The Flying Saucer Cafe  (Sipri Bazaar)
    ------------------------------------------------------------------
    rid := gen_random_uuid(); owner := gen_random_uuid();
    INSERT INTO restaurants
        (id, name, description, phone, address, city, latitude, longitude, open,
         average_delivery_time, rating, cuisine, opening_time, closing_time,
         active, deleted, owner_id, created_at, updated_at)
    VALUES
        (rid, 'The Flying Saucer Cafe',
         'Fusion cafe known for paneer tikka pizza and peri-peri fries.',
         '+91 9181181181', 'Sipri Bazaar', 'Jhansi',
         25.4391, 78.5968, true, 35, 4.2, 'Cafe',
         TIME '11:00', TIME '23:30', true, false, owner, now(), now());

    cat := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat, 'Pizza and Fries', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Paneer Tikka Pizza', 'Pizza topped with spiced paneer tikka', 320.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Peri Peri Fries',    'Fries tossed in peri-peri seasoning',   160.00, true, true, cat, now(), now()),
        (gen_random_uuid(), 'Margherita Pizza',   'Classic cheese and tomato pizza',       260.00, true, true, cat, now(), now());

    cat2 := gen_random_uuid();
    INSERT INTO menu_categories (id, name, restaurant_id, created_at, updated_at)
        VALUES (cat2, 'Burgers and Shakes', rid, now(), now());
    INSERT INTO menu_items (id, name, description, price, available, vegetarian, category_id, created_at, updated_at) VALUES
        (gen_random_uuid(), 'Veg Cheese Burger', 'Veg patty with cheese and veggies', 180.00, true, true,  cat2, now(), now()),
        (gen_random_uuid(), 'Chicken Burger',    'Grilled chicken patty burger',      220.00, true, false, cat2, now(), now()),
        (gen_random_uuid(), 'Oreo Shake',        'Thick shake blended with Oreo',     150.00, true, true,  cat2, now(), now());

END $$;
