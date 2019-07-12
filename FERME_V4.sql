-- CREACION DE USUARIO SQL
CREATE USER FERME IDENTIFIED BY "ferme2018"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- ASIGNACION DE ROLES
GRANT "CONNECT" TO FERME ;
GRANT "RESOURCE" TO FERME ;

CREATE TABLE acceso (
    id             INTEGER NOT NULL,
    usuario        VARCHAR2(50) NOT NULL,
    clave          VARCHAR2(50) NOT NULL,
    usuario_id     INTEGER,
    pregunta       VARCHAR2(150),
    respuesta      VARCHAR2(50),
    proveedor_id   INTEGER
);

CREATE UNIQUE INDEX acceso__idx ON
    acceso ( usuario_id ASC );

CREATE UNIQUE INDEX acceso__idxv1 ON
    acceso ( proveedor_id ASC );

ALTER TABLE acceso ADD CONSTRAINT acceso_pk PRIMARY KEY ( id );

CREATE TABLE compra (
    id                INTEGER NOT NULL,
    num_orden         INTEGER NOT NULL,
    fecha_documento   DATE NOT NULL,
    recepcionado      CHAR(1) NOT NULL,
    proveedor_id      INTEGER NOT NULL
);

ALTER TABLE compra ADD CONSTRAINT compra_pk PRIMARY KEY ( id );

CREATE TABLE configuracion (
    id          INTEGER NOT NULL,
    empresa     VARCHAR2(30) NOT NULL,
    rut         VARCHAR2(10) NOT NULL,
    direccion   VARCHAR2(50) NOT NULL,
    correo      VARCHAR2(50) NOT NULL,
    moneda      char (1) NOT NULL
);

ALTER TABLE configuracion ADD CONSTRAINT configuracion_pk PRIMARY KEY ( id );

CREATE TABLE detalle_compra (
    id            INTEGER NOT NULL,
    cantidad      INTEGER NOT NULL,
    compra_id     INTEGER NOT NULL,
    producto_id   INTEGER NOT NULL,
    aceptada      CHAR(1),
    observacion   VARCHAR(255)
);

ALTER TABLE detalle_compra ADD CONSTRAINT detalle_compra_pk PRIMARY KEY ( id );

CREATE TABLE detalle_venta (
    id            INTEGER NOT NULL,
    precio        INTEGER NOT NULL,
    cantidad      INTEGER NOT NULL,
    venta_id      INTEGER NOT NULL,
    producto_id   INTEGER NOT NULL
);

ALTER TABLE detalle_venta ADD CONSTRAINT detalle_venta_pk PRIMARY KEY ( id );

CREATE TABLE familia_producto (
    id            INTEGER NOT NULL,
    id_familia    VARCHAR2(3) NOT NULL,
    descripcion   VARCHAR2(30) NOT NULL
);

ALTER TABLE familia_producto ADD CONSTRAINT familia_producto_pk PRIMARY KEY ( id );

CREATE TABLE log_precio (
    id               INTEGER NOT NULL,
    id_producto      INTEGER NOT NULL,
    fecha            DATE NOT NULL,
    precio_antiguo   INTEGER NOT NULL,
    precio_nuevo     INTEGER NOT NULL
);

ALTER TABLE log_precio ADD CONSTRAINT log_precio_pk PRIMARY KEY ( id );

CREATE TABLE producto (
    id                 INTEGER NOT NULL,
    id_producto        VARCHAR2(17) NOT NULL,
    descripcion        VARCHAR2(50) NOT NULL,
    precio             INTEGER NOT NULL,
    stock              INTEGER NOT NULL,
    stock_critico      INTEGER NOT NULL,
    tipo_producto_id   INTEGER NOT NULL
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( id );

CREATE TABLE proveedor (
    id          INTEGER NOT NULL,
    rut         VARCHAR2(10) NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    direccion   VARCHAR2(50) NOT NULL,
    telefono    VARCHAR2(12) NOT NULL,
    rubro       VARCHAR2(20) NOT NULL,
    mail        VARCHAR2(50) NOT NULL
);

ALTER TABLE proveedor ADD CONSTRAINT proveedor_pk PRIMARY KEY ( id );

CREATE TABLE tipo_producto (
    id                    INTEGER NOT NULL,
    secuencia             INTEGER NOT NULL,
    descripcion           VARCHAR2(50) NOT NULL,
    familia_producto_id   INTEGER NOT NULL
);

ALTER TABLE tipo_producto ADD CONSTRAINT tipo_producto_pk PRIMARY KEY ( id );

CREATE TABLE usuario (
    id             INTEGER NOT NULL,
    rut            VARCHAR2(12) NOT NULL,
    nombre         VARCHAR2(50) NOT NULL,
    direccion      VARCHAR2(50) NOT NULL,
    telefono       VARCHAR2(15) NOT NULL,
    mail           VARCHAR2(50) NOT NULL,
    cargo          VARCHAR2(30),
    tipo_usuario   char (1) NOT NULL,
    tipo_cliente   char (1)
);

ALTER TABLE usuario ADD CONSTRAINT usuario_pk PRIMARY KEY ( id );

CREATE TABLE venta (
    id                INTEGER NOT NULL,
    tipo_documento    char(1) NOT NULL,
    num_documento     INTEGER NOT NULL,
    fecha_documento   DATE NOT NULL,
    id_cliente        INTEGER NOT NULL,
    total             INTEGER NOT NULL,
    usuario_id        INTEGER NOT NULL
);

ALTER TABLE venta ADD CONSTRAINT venta_pk PRIMARY KEY ( id );

CREATE TABLE visita (
    id        INTEGER NOT NULL,
    fecha     DATE,
    usuario   VARCHAR2(50)
);

ALTER TABLE visita ADD CONSTRAINT visita_pk PRIMARY KEY ( id );

ALTER TABLE acceso ADD CONSTRAINT acceso_proveedor_fk FOREIGN KEY ( proveedor_id )
    REFERENCES proveedor ( id );

ALTER TABLE acceso ADD CONSTRAINT acceso_usuario_fk FOREIGN KEY ( usuario_id )
    REFERENCES usuario ( id );

ALTER TABLE compra ADD CONSTRAINT compra_proveedor_fk FOREIGN KEY ( proveedor_id )
    REFERENCES proveedor ( id );

ALTER TABLE detalle_compra ADD CONSTRAINT detalle_compra_compra_fk FOREIGN KEY ( compra_id )
    REFERENCES compra ( id );

ALTER TABLE detalle_compra ADD CONSTRAINT detalle_compra_producto_fk FOREIGN KEY ( producto_id )
    REFERENCES producto ( id );

ALTER TABLE detalle_venta ADD CONSTRAINT detalle_venta_producto_fk FOREIGN KEY ( producto_id )
    REFERENCES producto ( id );

ALTER TABLE detalle_venta ADD CONSTRAINT detalle_venta_venta_fk FOREIGN KEY ( venta_id )
    REFERENCES venta ( id );

ALTER TABLE producto ADD CONSTRAINT producto_tipo_producto_fk FOREIGN KEY ( tipo_producto_id )
    REFERENCES tipo_producto ( id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE tipo_producto ADD CONSTRAINT tipo_producto_fam_prod_fk FOREIGN KEY ( familia_producto_id )
    REFERENCES familia_producto ( id );

ALTER TABLE venta ADD CONSTRAINT venta_usuario_fk FOREIGN KEY ( usuario_id )
    REFERENCES usuario ( id );

--SECUENCIAS
CREATE SEQUENCE SQ_ACCESO ORDER;
CREATE SEQUENCE SQ_COMPRA ORDER;
CREATE SEQUENCE SQ_DETALLE_COMPRA ORDER;
CREATE SEQUENCE SQ_DETALLE_VENTA ORDER;
CREATE SEQUENCE SQ_FAMILIA_PRODUCTO ORDER;
CREATE SEQUENCE SQ_TIPO_PRODUCTO ORDER;
CREATE SEQUENCE SQ_LOG_PRECIO ORDER;
CREATE SEQUENCE SQ_PRODUCTO ORDER;
CREATE SEQUENCE SQ_PROVEEDOR ORDER;
CREATE SEQUENCE SQ_USUARIO ORDER;
CREATE SEQUENCE SQ_VENTA ORDER;
CREATE SEQUENCE SQ_VISITA ORDER;

--TRIGGER PARA LOG_PRECIO
CREATE OR REPLACE TRIGGER TRG_LOG_PRECIO
AFTER UPDATE OF "PRECIO" ON "PRODUCTO"
FOR EACH ROW
BEGIN 
    IF UPDATING THEN
        INSERT INTO LOG_PRECIO VALUES (SQ_LOG_PRECIO.NEXTVAL,:OLD.ID_PRODUCTO,TO_DATE(TO_CHAR(SYSDATE, 'dd/mm/yyyy'),'dd/mm/yyyy'),:OLD.PRECIO,:NEW.PRECIO);
    END IF;
END;

CREATE OR REPLACE TRIGGER TGR_ID_VENTAS 
BEFORE INSERT ON VENTA
FOR EACH ROW
WHEN ( NEW.ID = 0 )
BEGIN
  SELECT SQ_VENTA.NEXTVAL INTO :NEW.ID FROM dual;
END;

CREATE OR REPLACE TRIGGER TGR_ID_DETALLE_VENTA 
BEFORE INSERT ON DETALLE_VENTA
FOR EACH ROW
WHEN ( NEW.ID = 0 )
BEGIN
  SELECT SQ_DETALLE_VENTA.NEXTVAL INTO :NEW.ID FROM dual;
END;

CREATE OR REPLACE TRIGGER TGR_ID_VISITA
BEFORE INSERT ON VISITA
FOR EACH ROW
WHEN (NEW.ID = 0)
BEGIN
  SELECT SQ_VISITA.NEXTVAL,SYSDATE INTO :NEW.ID,:NEW.FECHA FROM dual;
END;