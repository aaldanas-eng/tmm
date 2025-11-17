-- Script de políticas de seguridad (Row Level Security)
-- Ejecutar después del setup.sql

-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE spas ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Políticas para la tabla 'users'
-- Los administradores pueden ver todos los usuarios
CREATE POLICY "Admins can view all users" ON users
    FOR ALL USING (auth.role() = 'authenticated' AND 
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- Los usuarios pueden ver solo su propio perfil
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.role() = 'authenticated' AND 
    (id = auth.uid() OR EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')));

-- Los administradores pueden insertar usuarios
CREATE POLICY "Admins can insert users" ON users
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND 
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- Los administradores pueden actualizar usuarios
CREATE POLICY "Admins can update users" ON users
    FOR UPDATE USING (auth.role() = 'authenticated' AND 
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.role() = 'authenticated' AND id = auth.uid());

-- Políticas para la tabla 'spas'
-- Todos los usuarios autenticados pueden ver los spas
CREATE POLICY "Authenticated users can view spas" ON spas
    FOR SELECT USING (auth.role() = 'authenticated');

-- Solo administradores pueden modificar spas
CREATE POLICY "Only admins can modify spas" ON spas
    FOR ALL USING (auth.role() = 'authenticated' AND 
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- Políticas para la tabla 'sessions'
-- Los usuarios pueden ver sus propias sesiones
CREATE POLICY "Users can view own sessions" ON sessions
    FOR SELECT USING (auth.role() = 'authenticated' AND 
    (user_id = auth.uid() OR EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')));

-- Los usuarios pueden insertar sus propias sesiones
CREATE POLICY "Users can insert own sessions" ON sessions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid());

-- Los usuarios pueden actualizar sus propias sesiones
CREATE POLICY "Users can update own sessions" ON sessions
    FOR UPDATE USING (auth.role() = 'authenticated' AND user_id = auth.uid());

-- Los usuarios pueden eliminar sus propias sesiones
CREATE POLICY "Users can delete own sessions" ON sessions
    FOR DELETE USING (auth.role() = 'authenticated' AND user_id = auth.uid());
