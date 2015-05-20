/*
 *  MICO --- an Open Source CORBA implementation
 *  Copyright (c) 1997-2006 by The Mico Team
 *
 *  This file was automatically generated. DO NOT EDIT!
 */

#include <ggt.h>


using namespace std;

//--------------------------------------------------------
//  Implementation of stubs
//--------------------------------------------------------

/*
 * Base interface for class unit
 */

ggt::unit::~unit()
{
}

void *
ggt::unit::_narrow_helper( const char *_repoid )
{
  if( strcmp( _repoid, "IDL:ggt/unit:1.0" ) == 0 )
    return (void *)this;
  return NULL;
}

ggt::unit_ptr
ggt::unit::_narrow( CORBA::Object_ptr _obj )
{
  ggt::unit_ptr _o;
  if( !CORBA::is_nil( _obj ) ) {
    void *_p;
    if( (_p = _obj->_narrow_helper( "IDL:ggt/unit:1.0" )))
      return _duplicate( (ggt::unit_ptr) _p );
    if (!strcmp (_obj->_repoid(), "IDL:ggt/unit:1.0") || _obj->_is_a_remote ("IDL:ggt/unit:1.0")) {
      _o = new ggt::unit_stub;
      _o->CORBA::Object::operator=( *_obj );
      return _o;
    }
  }
  return _nil();
}

ggt::unit_ptr
ggt::unit::_narrow( CORBA::AbstractBase_ptr _obj )
{
  return _narrow (_obj->_to_object());
}

class _Marshaller_ggt_unit : public ::CORBA::StaticTypeInfo {
    typedef ggt::unit_ptr _MICO_T;
  public:
    ~_Marshaller_ggt_unit();
    StaticValueType create () const;
    void assign (StaticValueType dst, const StaticValueType src) const;
    void free (StaticValueType) const;
    void release (StaticValueType) const;
    ::CORBA::Boolean demarshal (::CORBA::DataDecoder&, StaticValueType) const;
    void marshal (::CORBA::DataEncoder &, StaticValueType) const;
};


_Marshaller_ggt_unit::~_Marshaller_ggt_unit()
{
}

::CORBA::StaticValueType _Marshaller_ggt_unit::create() const
{
  return (StaticValueType) new _MICO_T( 0 );
}

void _Marshaller_ggt_unit::assign( StaticValueType d, const StaticValueType s ) const
{
  *(_MICO_T*) d = ::ggt::unit::_duplicate( *(_MICO_T*) s );
}

void _Marshaller_ggt_unit::free( StaticValueType v ) const
{
  ::CORBA::release( *(_MICO_T *) v );
  delete (_MICO_T*) v;
}

void _Marshaller_ggt_unit::release( StaticValueType v ) const
{
  ::CORBA::release( *(_MICO_T *) v );
}

::CORBA::Boolean _Marshaller_ggt_unit::demarshal( ::CORBA::DataDecoder &dc, StaticValueType v ) const
{
  ::CORBA::Object_ptr obj;
  if (!::CORBA::_stc_Object->demarshal(dc, &obj))
    return FALSE;
  *(_MICO_T *) v = ::ggt::unit::_narrow( obj );
  ::CORBA::Boolean ret = ::CORBA::is_nil (obj) || !::CORBA::is_nil (*(_MICO_T *)v);
  ::CORBA::release (obj);
  return ret;
}

void _Marshaller_ggt_unit::marshal( ::CORBA::DataEncoder &ec, StaticValueType v ) const
{
  ::CORBA::Object_ptr obj = *(_MICO_T *) v;
  ::CORBA::_stc_Object->marshal( ec, &obj );
}

::CORBA::StaticTypeInfo *_marshaller_ggt_unit;


/*
 * Stub interface for class unit
 */

ggt::unit_stub::~unit_stub()
{
}

#ifndef MICO_CONF_NO_POA

void *
POA_ggt::unit::_narrow_helper (const char * repoid)
{
  if (strcmp (repoid, "IDL:ggt/unit:1.0") == 0) {
    return (void *) this;
  }
  return NULL;
}

POA_ggt::unit *
POA_ggt::unit::_narrow (PortableServer::Servant serv) 
{
  void * p;
  if ((p = serv->_narrow_helper ("IDL:ggt/unit:1.0")) != NULL) {
    serv->_add_ref ();
    return (POA_ggt::unit *) p;
  }
  return NULL;
}

ggt::unit_stub_clp::unit_stub_clp ()
{
}

ggt::unit_stub_clp::unit_stub_clp (PortableServer::POA_ptr poa, CORBA::Object_ptr obj)
  : CORBA::Object(*obj), PortableServer::StubBase(poa)
{
}

ggt::unit_stub_clp::~unit_stub_clp ()
{
}

#endif // MICO_CONF_NO_POA

CORBA::Long ggt::unit_stub::setneighbors( CORBA::Long _par_pidleft, CORBA::Long _par_pidright )
{
  CORBA::StaticAny _sa_pidleft( CORBA::_stc_long, &_par_pidleft );
  CORBA::StaticAny _sa_pidright( CORBA::_stc_long, &_par_pidright );
  CORBA::Long _res;
  CORBA::StaticAny __res( CORBA::_stc_long, &_res );

  CORBA::StaticRequest __req( this, "setneighbors" );
  __req.add_in_arg( &_sa_pidleft );
  __req.add_in_arg( &_sa_pidright );
  __req.set_result( &__res );

  __req.invoke();

  mico_sii_throw( &__req, 
    0);
  return _res;
}


#ifndef MICO_CONF_NO_POA

CORBA::Long
ggt::unit_stub_clp::setneighbors( CORBA::Long _par_pidleft, CORBA::Long _par_pidright )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      CORBA::Long __res;

      #ifdef HAVE_EXCEPTIONS
      try {
      #endif
        __res = _myserv->setneighbors(_par_pidleft, _par_pidright);
      #ifdef HAVE_EXCEPTIONS
      }
      catch (...) {
        _myserv->_remove_ref();
        _postinvoke();
        throw;
      }
      #endif

      _myserv->_remove_ref();
      _postinvoke ();
      return __res;
    }
    _postinvoke ();
  }

  return ggt::unit_stub::setneighbors(_par_pidleft, _par_pidright);
}

#endif // MICO_CONF_NO_POA

void ggt::unit_stub::setpm( CORBA::Long _par_pm )
{
  CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );
  CORBA::StaticRequest __req( this, "setpm" );
  __req.add_in_arg( &_sa_pm );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
ggt::unit_stub_clp::setpm( CORBA::Long _par_pm )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      _myserv->setpm(_par_pm);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  ggt::unit_stub::setpm(_par_pm);
}

#endif // MICO_CONF_NO_POA

void ggt::unit_stub::sendy( CORBA::Long _par_y )
{
  CORBA::StaticAny _sa_y( CORBA::_stc_long, &_par_y );
  CORBA::StaticRequest __req( this, "sendy" );
  __req.add_in_arg( &_sa_y );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
ggt::unit_stub_clp::sendy( CORBA::Long _par_y )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      _myserv->sendy(_par_y);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  ggt::unit_stub::sendy(_par_y);
}

#endif // MICO_CONF_NO_POA

void ggt::unit_stub::query()
{
  CORBA::StaticRequest __req( this, "query" );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
ggt::unit_stub_clp::query()
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      _myserv->query();
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  ggt::unit_stub::query();
}

#endif // MICO_CONF_NO_POA

void ggt::unit_stub::response( CORBA::Long _par_y )
{
  CORBA::StaticAny _sa_y( CORBA::_stc_long, &_par_y );
  CORBA::StaticRequest __req( this, "response" );
  __req.add_in_arg( &_sa_y );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
ggt::unit_stub_clp::response( CORBA::Long _par_y )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      _myserv->response(_par_y);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  ggt::unit_stub::response(_par_y);
}

#endif // MICO_CONF_NO_POA

void ggt::unit_stub::close()
{
  CORBA::StaticRequest __req( this, "close" );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
ggt::unit_stub_clp::close()
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_ggt::unit * _myserv = POA_ggt::unit::_narrow (_serv);
    if (_myserv) {
      _myserv->close();
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  ggt::unit_stub::close();
}

#endif // MICO_CONF_NO_POA

struct __tc_init_GGT {
  __tc_init_GGT()
  {
    _marshaller_ggt_unit = new _Marshaller_ggt_unit;
  }

  ~__tc_init_GGT()
  {
    delete static_cast<_Marshaller_ggt_unit*>(_marshaller_ggt_unit);
  }
};

static __tc_init_GGT __init_GGT;

//--------------------------------------------------------
//  Implementation of skeletons
//--------------------------------------------------------

// PortableServer Skeleton Class for interface ggt::unit
POA_ggt::unit::~unit()
{
}

::ggt::unit_ptr
POA_ggt::unit::_this ()
{
  CORBA::Object_var obj = PortableServer::ServantBase::_this();
  return ::ggt::unit::_narrow (obj);
}

CORBA::Boolean
POA_ggt::unit::_is_a (const char * repoid)
{
  if (strcmp (repoid, "IDL:ggt/unit:1.0") == 0) {
    return TRUE;
  }
  return FALSE;
}

CORBA::InterfaceDef_ptr
POA_ggt::unit::_get_interface ()
{
  CORBA::InterfaceDef_ptr ifd = PortableServer::ServantBase::_get_interface ("IDL:ggt/unit:1.0");

  if (CORBA::is_nil (ifd)) {
    mico_throw (CORBA::OBJ_ADAPTER (0, CORBA::COMPLETED_NO));
  }

  return ifd;
}

CORBA::RepositoryId
POA_ggt::unit::_primary_interface (const PortableServer::ObjectId &, PortableServer::POA_ptr)
{
  return CORBA::string_dup ("IDL:ggt/unit:1.0");
}

CORBA::Object_ptr
POA_ggt::unit::_make_stub (PortableServer::POA_ptr poa, CORBA::Object_ptr obj)
{
  return new ::ggt::unit_stub_clp (poa, obj);
}

bool
POA_ggt::unit::dispatch (CORBA::StaticServerRequest_ptr __req)
{
  #ifdef HAVE_EXCEPTIONS
  try {
  #endif
    switch (mico_string_hash (__req->op_name(), 11)) {
    case 0:
      if( strcmp( __req->op_name(), "close" ) == 0 ) {

        if( !__req->read_args() )
          return true;

        close();
        __req->write_results();
        return true;
      }
      break;
    case 3:
      if( strcmp( __req->op_name(), "setpm" ) == 0 ) {
        CORBA::Long _par_pm;
        CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );

        __req->add_in_arg( &_sa_pm );

        if( !__req->read_args() )
          return true;

        setpm( _par_pm );
        __req->write_results();
        return true;
      }
      if( strcmp( __req->op_name(), "sendy" ) == 0 ) {
        CORBA::Long _par_y;
        CORBA::StaticAny _sa_y( CORBA::_stc_long, &_par_y );

        __req->add_in_arg( &_sa_y );

        if( !__req->read_args() )
          return true;

        sendy( _par_y );
        __req->write_results();
        return true;
      }
      break;
    case 4:
      if( strcmp( __req->op_name(), "query" ) == 0 ) {

        if( !__req->read_args() )
          return true;

        query();
        __req->write_results();
        return true;
      }
      break;
    case 8:
      if( strcmp( __req->op_name(), "response" ) == 0 ) {
        CORBA::Long _par_y;
        CORBA::StaticAny _sa_y( CORBA::_stc_long, &_par_y );

        __req->add_in_arg( &_sa_y );

        if( !__req->read_args() )
          return true;

        response( _par_y );
        __req->write_results();
        return true;
      }
      break;
    case 9:
      if( strcmp( __req->op_name(), "setneighbors" ) == 0 ) {
        CORBA::Long _par_pidleft;
        CORBA::StaticAny _sa_pidleft( CORBA::_stc_long, &_par_pidleft );
        CORBA::Long _par_pidright;
        CORBA::StaticAny _sa_pidright( CORBA::_stc_long, &_par_pidright );

        CORBA::Long _res;
        CORBA::StaticAny __res( CORBA::_stc_long, &_res );
        __req->add_in_arg( &_sa_pidleft );
        __req->add_in_arg( &_sa_pidright );
        __req->set_result( &__res );

        if( !__req->read_args() )
          return true;

        _res = setneighbors( _par_pidleft, _par_pidright );
        __req->write_results();
        return true;
      }
      break;
    }
  #ifdef HAVE_EXCEPTIONS
  } catch( CORBA::SystemException_catch &_ex ) {
    __req->set_exception( _ex->_clone() );
    __req->write_results();
    return true;
  } catch( ... ) {
    CORBA::UNKNOWN _ex (CORBA::OMGVMCID | 1, CORBA::COMPLETED_MAYBE);
    __req->set_exception (_ex->_clone());
    __req->write_results ();
    return true;
  }
  #endif

  return false;
}

void
POA_ggt::unit::invoke (CORBA::StaticServerRequest_ptr __req)
{
  if (dispatch (__req)) {
      return;
  }

  CORBA::Exception * ex = 
    new CORBA::BAD_OPERATION (0, CORBA::COMPLETED_NO);
  __req->set_exception (ex);
  __req->write_results();
}

