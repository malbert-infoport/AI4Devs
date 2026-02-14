namespace InfoportOneAdmon.Back.Services
{
    public static class ServiceConsts
    {
        public struct Problems
        {
            public struct Attachments
            {
                public const string ATTACHMENT_FILE_NOT_FOUND = "ATTACHMENT_FILE_NOT_FOUND";
            }
        }

        public struct Validations
        {
            public const string FORBIDDEN_FIELD_CHANGE = "FORBIDDEN_FIELD_CHANGE";

            public struct AjusteLiquidacion
            {
                public const string CannotModifyIfLinkedToLiquidacion =
                    "AJUSTELIQUIDACION_CANNOTMODIFYIFLINKEDTOLIQUIDACION";
            }

            public struct AttachmentType
            {
                public const string ATTACHMENT_TYPE_RESERVED = "ATTACHMENT_TYPE_RESERVED";
            }

            public struct ClasificacionVehiculo
            {
                public const string CANT_DELETE = "CLASIFICACIONVEHICULO_CANT_DELETE";
            }

            public struct ClientCredentialsIPVRates
            {
                public const string SECURITY_COMPANY_ID_NOT_AVAILABLE =
                    "CLIENT_CREDENTIALS_SECURITY_COMPANY_ID_NOT_AVAILABLE";

                public const string USER_CONTEXT_NOT_AVAILABLE =
                    "CLIENT_CREDENTIALS_USER_CONTEXT_NOT_AVAILABLE";
            }

            public struct Course
            {
                public const string COURSE_DELETE_HAS_WORKER = "COURSE_DELETE_HAS_WORKER";
            }

            public struct Delegacion
            {
                public const string DELEGACION_ERROR = "DELEGACION_ERROR";
                public const string INTERCAMBIO_NOEXISTE = "INTERCAMBIO_NOEXISTE";
            }

            public struct Distancia
            {
                public const string EN_USO = "DISTANCIA_EN_USO";
            }

            public struct Empleado
            {
                public const string VEHICULOASOCIADO_TIPOINVALIDO =
                    "EMPLEADO_VEHICULOASOCIADO_TIPOINVALIDO";
            }

            public struct Empresas
            {
                public const string EMPRESA_EXISTS = "EMPRESA_EXISTS";
                public const string EMPRESA_NOEXISTE = "EMPRESA_NOEXISTE";
                public const string EMPRESA_NOEXISTE_DETALLE = "EMPRESA_NOEXISTE_DETALLE";
                public const string NUMERODOCUMENTO_REQUIRED = "EMPRESA_NUMERODOCUMENTO_REQUIRED";
                public const string NUMERODOCUMENTO_UNIQUE = "EMPRESA_NUMERODOCUMENTO_UNIQUE";
                public const string REQUIERE_TIPO = "EMPRESA_REQUIERE_TIPO";

                public const string SOLO_UNA_DIRECCION_DEFECTO =
                    "EMPRESA_SOLO_UNA_DIRECCION_DEFECTO";

                public const string TIPOEMPRESA_NOEXISTE = "TIPOEMPRESA_NOEXISTE";
                public const string TIPOEMPRESA_NOEXISTE_DETALLE = "TIPOEMPRESA_NOEXISTE_DETALLE";
                public const string TIPOS_EMPRESA_NO_COMPATIBLES = "EMPRESA_TIPOS_NO_COMPATIBLES";

                public const string TIPOS_EMPRESA_NO_COMPATIBLES_DETALLE =
                    "EMPRESA_TIPOS_NO_COMPATIBLES_DETALLE";
            }

            public struct Entities
            {
                public const string ENTITY_VIAJE = "ENTITY_VIAJE";
            }

            public struct FacturadorExterno
            {
                public const string ARCHIVO_GENERADO_CORRECTAMENTE =
                    "FACTURADOR_EXTERNO_ARCHIVO_GENERADO_CORRECTAMENTE";

                public const string B2B_WEBHOOK_SIGNATURE_INVALID =
                    "FACTURADOR_EXTERNO_B2B_WEBHOOK_SIGNATURE_INVALID";

                public const string DOCUMENTOS_ENVIADOS_CORRECTAMENTE =
                    "FACTURADOR_EXTERNO_DOCUMENTOS_ENVIADOS_CORRECTAMENTE";

                public const string ERROR_PROCESAR_ENVIO =
                    "FACTURADOR_EXTERNO_ERROR_PROCESAR_ENVIO";

                public const string LISTA_VIAJES_EMPTY = "FACTURADOR_EXTERNO_LISTA_VIAJES_EMPTY";

                public const string NO_CONFIGURACION = "FACTURADOR_EXTERNO_NO_CONFIGURACION";

                public const string PROVEEDOR_NO_IMPLEMENTADO =
                    "FACTURADOR_EXTERNO_PROVEEDOR_NO_IMPLEMENTADO";

                public const string SECURITYCOMPANY_SIN_INTEGRACION =
                    "FACTURADOR_EXTERNO_SECURITYCOMPANY_SIN_INTEGRACION";

                public const string TARIFA_FALTAN_DATOS = "FACTURADOR_EXTERNO_TARIFA_FALTAN_DATOS";
                public const string VIAJE_CARGADOR_KM = "FACTURADOR_EXTERNO_VIAJE_CARGADOR_KM";
                public const string VIAJE_NO_EXISTE = "FACTURADOR_EXTERNO_VIAJE_NO_EXISTE";

                public const string VIAJE_NO_SECURITYCOMPANY =
                    "FACTURADOR_EXTERNO_VIAJE_NO_SECURITYCOMPANY";

                public const string VIAJE_NO_VALORADO = "FACTURADOR_EXTERNO_VIAJE_NO_VALORADO";

                public const string VIAJE_SIN_CARGADOR_FACTURABLE =
                    "FACTURADOR_EXTERNO_VIAJE_SIN_CARGADOR_FACTURABLE";

                public const string VIAJE_SIN_CLIENTE = "FACTURADOR_EXTERNO_VIAJE_SIN_CLIENTE";

                public const string VIAJE_SIN_EQUIPAMIENTO =
                    "FACTURADOR_EXTERNO_VIAJE_SIN_EQUIPAMIENTO";
            }

            public struct Helix6GeneralValidations
            {
                public const string HELIX6VALIDATION_ENTITY_NOT_EXISTS =
                    "HELIX6VALIDATION_ENTITY_NOT_EXISTS";
            }

            public struct InformeDCT
            {
                public const string OBSERVACIONES_DEFAULT = "INFORME_DCT_OBSERVACIONES_DEFAULT";
                public const string PIE_DE_INFORME_DEFAULT = "INFORME_DCT_PIE_DE_INFORME_DEFAULT";
                public const string PIE_DE_PAGINA_DEFAULT = "INFORME_DCT_PIE_DE_PAGINA_DEFAULT";
            }

            public struct IntCorreoConfiguracion
            {
                public const string CONFIG_NOT_ACTIVE = "INTCORREOCONFIGURATION_CONFIG_NOT_ACTIVE";
                public const string CONFIG_NOT_FOUND = "INTCORREOCONFIGURATION_CONFIG_NOT_FOUND";
                public const string TEST_MAIL_ERROR = "INTCORREOCONFIGURATION_TEST_MAIL_ERROR";
            }

            public struct IntegracionB2BRouter
            {
                public const string VIAJE_SIN_TARIFICACION_O_CARGADOR =
                    "B2BROUTER_VIAJE_SIN_TARIFICACION_O_CARGADOR";
            }

            public struct IntegracionSage
            {
                public const string VIAJE_SIN_TARIFICACION = "SAGE_VIAJE_SIN_TARIFICACION";
            }

            public struct IntegracionSecurityCompany
            {
                public const string SECURITYCOMPANY_MAIL_CONFIGURATION_MISSING =
                    "SECURITYCOMPANY_MAIL_CONFIGURATION_MISSING";

                public const string SOLO_UNA_INTEGRACION_FACTURACION =
                    "INTEGRACION_SECURITYCOMPANY_SOLO_UNA_INTEGRACION_FACTURACION";
            }

            public struct Liquidacion
            {
                public const string VIAJE_NO_TARIFICADO = "LIQUIDACION_VIAJE_NO_TARIFICADO";
                public const string VIAJE_SIN_CONDUCTORES = "VIAJE_SIN_CONDUCTORES";

                public const string VIAJE_SIN_SECURITYCOMPANY =
                    "LIQUIDACION_VIAJE_SIN_SECURITYCOMPANY";

                public const string IDS_REQUERIDOS = "LIQUIDACION_IDS_REQUERIDOS";

                public const string INFORME_ENVIADO_CONDUCTOR =
                    "LIQUIDACION_INFORME_ENVIADO_CONDUCTOR";

                public const string SMTP_SERVER_NOT_CONFIGURED =
                    "LIQUIDACION_SMTP_SERVER_NOT_CONFIGURED";

                public const string FROM_EMAIL_NOT_CONFIGURED =
                    "LIQUIDACION_FROM_EMAIL_NOT_CONFIGURED";

                public const string EMAIL_SUBJECT = "LIQUIDACION_EMAIL_SUBJECT";
                public const string EMAIL_BODY = "LIQUIDACION_EMAIL_BODY";
            }

            public struct Mensaje
            {
                public const string IDENTIFICADOR_CONTENEDOR = "IdentificadorContenedor";
                public const string MENSAJE_ERRORADJUNTO = "MENSAJE_ERRORADJUNTO";
                public const string MENSAJE_NOEXISTE = "MENSAJE_NOEXISTE";
                public const string MENSAJE_TIPOFLUJO_NOEXISTE = "MENSAJE_TIPOFLUJO_NOEXISTE";
                public const string MENSAJE_YAEXISTE = "MENSAJE_YAEXISTE";

                public const string NO_MAPPING_ATTACHMENT_TYPE =
                    "MENSAJE_NO_MAPPING_ATTACHMENT_TYPE";

                public const string NO_PENDIENTE = "MENSAJE_NO_PENDIENTE";
                public const string YA_TIENE_SECURITYCOMPANY = "MENSAJE_YA_TIENE_SECURITYCOMPANY";
            }

            public struct ProcesarAuditoria
            {
                public const string ASIGNAR_MAESTROS = "PROCESAR_AUDITORIA_ASIGNAR_MAESTROS";

                public const string ASOCIAR_MENSAJE_TIPO_INVALIDO =
                    "PROCESAR_AUDITORIA_ASOCIAR_MENSAJE_TIPO_INVALIDO";

                public const string ASOCIAR_MENSAJE_VIAJE_AUTOMATICO =
                    "PROCESAR_AUDITORIA_ASOCIAR_MENSAJE_VIAJE_AUTOMATICO";

                public const string DELEGACION_ASIGNADA = "PROCESAR_AUDITORIA_DELEGACION_ASIGNADA";
                public const string INSERTAR_VIAJE = "PROCESAR_AUDITORIA_INSERTAR_VIAJE";
                public const string LOCALIDAD = "PROCESAR_AUDITORIA_LOCALIDAD";

                public const string MENSAJE_NO_ENCONTRADO =
                    "PROCESAR_AUDITORIA_MENSAJE_NO_ENCONTRADO";

                public const string MENSAJE_YA_EN_VIAJE = "PROCESAR_AUDITORIA_MENSAJE_YA_EN_VIAJE";
                public const string PROCESANDO_MENSAJE = "PROCESAR_AUDITORIA_PROCESANDO_MENSAJE";
                public const string VIAJE_ESTADO_NO_VALIDO_PARA_ASOCIAR_MENSAJE =
                    "PROCESAR_AUDITORIA_VIAJE_ESTADO_NO_VALIDO_PARA_ASOCIAR_MENSAJE";

                public const string VIAJE_NO_ENCONTRADO = "PROCESAR_AUDITORIA_VIAJE_NO_ENCONTRADO";
            }

            public struct Project
            {
                public const string PROJECT_DELETE_HAS_WORKER = "PROJECT_DELETE_HAS_WORKER";
            }

            public struct ReportService
            {
                public const string ERROR_GENERATING_HTML = "REPORT_ERROR_GENERATING_HTML";

                public const string ERROR_GENERATING_MULTIPLE_PDF =
                    "REPORT_ERROR_GENERATING_MULTIPLE_PDF";

                public const string ERROR_GENERATING_PDF = "REPORT_ERROR_GENERATING_PDF";
                public const string NO_DATA_SOURCE = "REPORT_NO_DATA_SOURCE";
            }

            public struct Tarifas
            {
                public const string EXISTE_TARIFA_DESCRIPCION = "EXISTE_TARIFA_DESCRIPCION";
                public const string HELIXVALIDATION_REQUIRED = "HELIXVALIDATION_REQUIRED";

                public const string MESSAGE_VALIDITY_DATES_OVERLAPPED =
                    "MESSAGE_VALIDITY_DATES_OVERLAPPED";

                public const string RECARGO_NO_EXISTE_EN_TARIFA = "RECARGO_NO_EXISTE_EN_TARIFA";
                public const string TARIFA_ESTADO_INCORRECTO = "TARIFA_ESTADO_INCORRECTO";

                public const string TARIFA_IMPORTE_MANUAL_APLICADO =
                    "TARIFA_IMPORTE_MANUAL_APLICADO";

                public const string TARIFA_TIPO_TARIFA_NO_EDITABLE =
                    "TARIFA_TIPO_TARIFA_NO_EDITABLE";

                public const string TARIFA_VACIA = "TARIFA_VACIA";

                public const string TARIFA_VERSION_KEY_NO_EDITABLE =
                    "TARIFA_VERSION_KEY_NO_EDITABLE";

                public const string TARIFICACION_NOEXISTE = "TARIFICACION_NOEXISTE";

                public const string TIPO_SERVICIO_TARIFICABLE_NO_CONFIGURADO_PARA_TIPO_OPERACION =
                    "TIPO_SERVICIO_TARIFICABLE_NO_CONFIGURADO_PARA_TIPO_OPERACION";

                public const string VALIDATION_NEW_VALIDITY_GREATER_THAN_PREVIOUS =
                    "VALIDATION_NEW_VALIDITY_GREATER_THAN_PREVIOUS";

                public const string VALIDATION_VALIDITY_DATES = "VALIDATION_VALIDITY_DATES";
            }

            public struct TipoBulto
            {
                public const string EN_USO = "TIPOBULTO_EN_USO";
            }

            public struct TipoIntervencion
            {
                public const string CANT_DELETE = "TIPOINTERVENCION_CANT_DELETE";
            }

            public struct Valenciaport
            {
                public const string VALENCIAPORT_CONFIGURATION_MISSING =
                    "VALENCIAPORT_CONFIGURATION_MISSING";

                public const string VALENCIAPORT_DOCUMENT_MISSING = "VALENCIAPORT_DOCUMENT_MISSING";
            }

            public struct Vehiculo
            {
                public const string MAX_2_EXTINTORES = "VEHICULO_MAX_2_EXTINTORES";
                public const string NO_ENCONTRADO = "VEHICULO_NO_ENCONTRADO";
                public const string NO_ENCONTRADO_DETALLE = "VEHICULO_NO_ENCONTRADO_DETALLE";
                public const string SIN_DELEGACION = "VEHICULO_SIN_DELEGACION";
                public const string SIN_DELEGACION_DETALLE = "VEHICULO_SIN_DELEGACION_DETALLE";
                public const string YA_EXISTE = "VEHICULO_YA_EXISTE";
                public const string YA_EXISTE_DETALLE = "VEHICULO_YA_EXISTE_DETALLE";
            }

            public struct ViajeCargador
            {
                public const string MISSING_DATA = "VIAJECARGADOR_MISSINGDATA";
            }

            public struct ViajeConductorVehiculo
            {
                public const string CONDUCTOR_ENVIO_MAIL_SIN_ANEXOS =
                    "CONDUCTOR_ENVIO_MAIL_SIN_ANEXOS";

                public const string CONDUCTOR_SIN_CORREO = "CONDUCTOR_SIN_CORREO";
                public const string ESTADO_NO_VALIDO = "VIAJECONDUCTORVEHICULO_ESTADO_NO_VALIDO";
                public const string YA_LIQUIDADO = "VIAJECONDUCTORVEHICULO_YA_LIQUIDADO";
            }

            public struct ViajeEquipamiento
            {
                public const string FORMATO_MATRICULA = "VIAJEEQUIPAMIENTO_FORMATO_MATRICULA";
                public const string LOCALIDAD_NOT_FOUND = "VIAJEEQUIPAMIENTO_LOCALIDAD_NOT_FOUND";

                public const string VIAJEEQUIPAMIENTO_ITEMNUMBER_NOTFOUND =
                    "VIAJEEQUIPAMIENTO_ITEMNUMBER_NOTFOUND";

                public const string VIAJEEQUIPAMIENTO_LOCALIZADOR_MISSING =
                    "VIAJEEQUIPAMIENTO_LOCALIZADOR_MISSING";

                public const string VIAJEEQUIPAMIENTO_REQUERIDO = "VIAJEEQUIPAMIENTO_REQUERIDO";
            }

            public struct ViajeEquipamientoMercancia
            {
                public const string DATOS_MERCANCIA_MISSING = "EQUIPAMIENTO_DATOSMERCANCIA_MISSING";
            }

            public struct Viajes
            {
                public const string AGENTE_TIPONOPERMITIDO = "AGENTE_TIPONOPERMITIDO";
                public const string AGENTE_TIPOREPETIDO = "AGENTE_TIPOREPETIDO";

                public const string ASIGNACION_IO_ENVIADA_EXITOSAMENTE =
                    "VIAJE_ASIGNACION_IO_ENVIADA_EXITOSAMENTE";

                public const string DATOS_CONDUCTOR_VEHICULO_REQUERIDO =
                    "DATOS_CONDUCTOR_VEHICULO_REQUERIDO";

                public const string EMPRESACARGADOR_FORBIDDEN_FIELD_CHANGE =
                    "EMPRESACARGADOR_FORBIDDEN_FIELD_CHANGE";

                public const string EQUIPAMIENTO_DATOSMERCANCIA_MISSING =
                    "EQUIPAMIENTO_DATOSMERCANCIA_MISSING";

                public const string EQUIPAMIENTO_NUMDOCUMENTO_REQUERIDO =
                    "EQUIPAMIENTO_NUMDOCUMENTO_REQUERIDO";

                public const string ERROR_ENVIO_NO_COMPLETADO = "VIAJE_ERROR_ENVIO_NO_COMPLETADO";
                public const string ERROR_INESPERADO = "VIAJE_ERROR_INESPERADO";
                public const string ERROR_VALIDACION = "VIAJE_ERROR_VALIDACION";
                public const string ESTADO_VIAJE_INCORRECTO = "ESTADO_VIAJE_INCORRECTO";
                public const string GUARDAREMPLEADO_REPEATEDTYPE = "GUARDAREMPLEADO_REPEATEDTYPE";
                public const string GUARDAREMPLEADO_SIZELIMIT = "GUARDAREMPLEADO_SIZELIMIT";

                public const string GUARDAREMPRESA_LOCALIDAD_MISSING =
                    "GUARDAREMPRESA_LOCALIDAD_MISSING";

                public const string INTERCAMBIO_REQUERIDO = "INTERCAMBIO_REQUERIDO";
                public const string LOCALIDAD_CANNOTDELETEUSED = "LOCALIDAD_CANNOTDELETEUSED";
                public const string OPERACION_NO_SOPORTADA = "OPERACION_NO_SOPORTADA";
                public const string OPERACION_REQUERIDA = "OPERACION_REQUERIDA";

                public const string SIN_INFORMACION_INTERCAMBIO =
                    "VIAJE_SIN_INFORMACION_INTERCAMBIO";

                public const string VIAJE_ACTIVACION_NO_PERMITIDA_TRASPASO =
                    "VIAJE_ACTIVACION_NO_PERMITIDA_TRASPASO";

                public const string VIAJE_MANUAL = "VIAJE_MANUAL";

                public const string VIAJE_TRASPASO_REQUIERE_VARIAS_SECURITYCOMPANY =
                    "VIAJE_TRASPASO_REQUIERE_VARIAS_SECURITYCOMPANY";

                public const string VIAJE_TRASPASO_SECURITYCOMPANY_DESTINO =
                    "VIAJE_TRASPASO_SECURITYCOMPANY_DESTINO";

                public const string VIAJE_YA_TRASPASADO = "VIAJE_YA_TRASPASADO";
            }


            public struct DocumentosConductor
            {
                public const string DOCUMENT_PREVIEW_NO_SELECTION = "DOCUMENT_PREVIEW_NO_SELECTION";
                public const string DOCUMENT_PREVIEW_ORDER_NOT_AVAILABLE = "DOCUMENT_PREVIEW_ORDER_NOT_AVAILABLE";
                public const string DOCUMENT_PREVIEW_DCT_NOT_AVAILABLE = "DOCUMENT_PREVIEW_DCT_NOT_AVAILABLE";
                public const string DOCUMENT_TECHNICAL_ERROR = "DOCUMENT_TECHNICAL_ERROR";
                public const string DOCUMENT_DOWNLOAD_DCT_NOT_AVAILABLE = "DOCUMENT_DOWNLOAD_DCT_NOT_AVAILABLE";
                public const string DOCUMENT_DOWNLOAD_TECHNICAL_ERROR = "DOCUMENT_DOWNLOAD_TECHNICAL_ERROR";
                public const string DOCUMENT_SEND_NO_SELECTION = "DOCUMENT_SEND_NO_SELECTION";
                public const string DOCUMENT_SEND_TECHNICAL_ERROR = "DOCUMENT_SEND_TECHNICAL_ERROR";
            }

            public struct Worker
            {
                public const string TRAINEE_WORKER_MUST_BE_FROM_AGENCY =
                    "TRAINEE_WORKER_MUST_BE_FROM_AGENCY";
            }
        }
    }
}