/*
 *  MICO --- an Open Source CORBA implementation
 *  Copyright (c) 1997-2006 by The Mico Team
 *
 *  This file was automatically generated. DO NOT EDIT!
 */

#include <chef.h>


using namespace std;

//--------------------------------------------------------
//  Implementation of stubs
//--------------------------------------------------------

/*
 * Base interface for class koordinator
 */

chef::koordinator::~koordinator()
{
}

void *
chef::koordinator::_narrow_helper( const char *_repoid )
{
  if( strcmp( _repoid, "IDL:chef/koordinator:1.0" ) == 0 )
    return (void *)this;
  return NULL;
}

chef::koordinator_ptr
chef::koordinator::_narrow( CORBA::Object_ptr _obj )
{
  chef::koordinator_ptr _o;
  if( !CORBA::is_nil( _obj ) ) {
    void *_p;
    if( (_p = _obj->_narrow_helper( "IDL:chef/koordinator:1.0" )))
      return _duplicate( (chef::koordinator_ptr) _p );
    if (!strcmp (_obj->_repoid(), "IDL:chef/koordinator:1.0") || _obj->_is_a_remote ("IDL:chef/koordinator:1.0")) {
      _o = new chef::koordinator_stub;
      _o->CORBA::Object::operator=( *_obj );
      return _o;
    }
  }
  return _nil();
}

chef::koordinator_ptr
chef::koordinator::_narrow( CORBA::AbstractBase_ptr _obj )
{
  return _narrow (_obj->_to_object());
}

class _Marshaller_chef_koordinator : public ::CORBA::StaticTypeInfo {
    typedef chef::koordinator_ptr _MICO_T;
  public:
    ~_Marshaller_chef_koordinator();
    StaticValueType create () const;
    void assign (StaticValueType dst, const StaticValueType src) const;
    void free (StaticValueType) const;
    void release (StaticValueType) const;
    ::CORBA::Boolean demarshal (::CORBA::DataDecoder&, StaticValueType) const;
    void marshal (::CORBA::DataEncoder &, StaticValueType) const;
};


_Marshaller_chef_koordinator::~_Marshaller_chef_koordinator()
{
}

::CORBA::StaticValueType _Marshaller_chef_koordinator::create() const
{
  return (StaticValueType) new _MICO_T( 0 );
}

void _Marshaller_chef_koordinator::assign( StaticValueType d, const StaticValueType s ) const
{
  *(_MICO_T*) d = ::chef::koordinator::_duplicate( *(_MICO_T*) s );
}

void _Marshaller_chef_koordinator::free( StaticValueType v ) const
{
  ::CORBA::release( *(_MICO_T *) v );
  delete (_MICO_T*) v;
}

void _Marshaller_chef_koordinator::release( StaticValueType v ) const
{
  ::CORBA::release( *(_MICO_T *) v );
}

::CORBA::Boolean _Marshaller_chef_koordinator::demarshal( ::CORBA::DataDecoder &dc, StaticValueType v ) const
{
  ::CORBA::Object_ptr obj;
  if (!::CORBA::_stc_Object->demarshal(dc, &obj))
    return FALSE;
  *(_MICO_T *) v = ::chef::koordinator::_narrow( obj );
  ::CORBA::Boolean ret = ::CORBA::is_nil (obj) || !::CORBA::is_nil (*(_MICO_T *)v);
  ::CORBA::release (obj);
  return ret;
}

void _Marshaller_chef_koordinator::marshal( ::CORBA::DataEncoder &ec, StaticValueType v ) const
{
  ::CORBA::Object_ptr obj = *(_MICO_T *) v;
  ::CORBA::_stc_Object->marshal( ec, &obj );
}

::CORBA::StaticTypeInfo *_marshaller_chef_koordinator;


/*
 * Stub interface for class koordinator
 */

chef::koordinator_stub::~koordinator_stub()
{
}

#ifndef MICO_CONF_NO_POA

void *
POA_chef::koordinator::_narrow_helper (const char * repoid)
{
  if (strcmp (repoid, "IDL:chef/koordinator:1.0") == 0) {
    return (void *) this;
  }
  return NULL;
}

POA_chef::koordinator *
POA_chef::koordinator::_narrow (PortableServer::Servant serv) 
{
  void * p;
  if ((p = serv->_narrow_helper ("IDL:chef/koordinator:1.0")) != NULL) {
    serv->_add_ref ();
    return (POA_chef::koordinator *) p;
  }
  return NULL;
}

chef::koordinator_stub_clp::koordinator_stub_clp ()
{
}

chef::koordinator_stub_clp::koordinator_stub_clp (PortableServer::POA_ptr poa, CORBA::Object_ptr obj)
  : CORBA::Object(*obj), PortableServer::StubBase(poa)
{
}

chef::koordinator_stub_clp::~koordinator_stub_clp ()
{
}

#endif // MICO_CONF_NO_POA

CORBA::Long chef::koordinator_stub::getsteeringval( CORBA::Long_out _par_pnum, CORBA::Long_out _par_wtime, CORBA::Long_out _par_term )
{
  CORBA::StaticAny _sa_pnum( CORBA::_stc_long, &_par_pnum );
  CORBA::StaticAny _sa_wtime( CORBA::_stc_long, &_par_wtime );
  CORBA::StaticAny _sa_term( CORBA::_stc_long, &_par_term );
  CORBA::Long _res;
  CORBA::StaticAny __res( CORBA::_stc_long, &_res );

  CORBA::StaticRequest __req( this, "getsteeringval" );
  __req.add_out_arg( &_sa_pnum );
  __req.add_out_arg( &_sa_wtime );
  __req.add_out_arg( &_sa_term );
  __req.set_result( &__res );

  __req.invoke();

  mico_sii_throw( &__req, 
    0);
  return _res;
}


#ifndef MICO_CONF_NO_POA

CORBA::Long
chef::koordinator_stub_clp::getsteeringval( CORBA::Long_out _par_pnum, CORBA::Long_out _par_wtime, CORBA::Long_out _par_term )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_chef::koordinator * _myserv = POA_chef::koordinator::_narrow (_serv);
    if (_myserv) {
      CORBA::Long __res;

      #ifdef HAVE_EXCEPTIONS
      try {
      #endif
        __res = _myserv->getsteeringval(_par_pnum, _par_wtime, _par_term);
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

  return chef::koordinator_stub::getsteeringval(_par_pnum, _par_wtime, _par_term);
}

#endif // MICO_CONF_NO_POA

CORBA::Long chef::koordinator_stub::hello( CORBA::Long _par_pid )
{
  CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
  CORBA::Long _res;
  CORBA::StaticAny __res( CORBA::_stc_long, &_res );

  CORBA::StaticRequest __req( this, "hello" );
  __req.add_in_arg( &_sa_pid );
  __req.set_result( &__res );

  __req.invoke();

  mico_sii_throw( &__req, 
    0);
  return _res;
}


#ifndef MICO_CONF_NO_POA

CORBA::Long
chef::koordinator_stub_clp::hello( CORBA::Long _par_pid )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_chef::koordinator * _myserv = POA_chef::koordinator::_narrow (_serv);
    if (_myserv) {
      CORBA::Long __res;

      #ifdef HAVE_EXCEPTIONS
      try {
      #endif
        __res = _myserv->hello(_par_pid);
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

  return chef::koordinator_stub::hello(_par_pid);
}

#endif // MICO_CONF_NO_POA

void chef::koordinator_stub::brief( CORBA::Long _par_pid, CORBA::Long _par_pm, CORBA::Long _par_ptime )
{
  CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
  CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );
  CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );
  CORBA::StaticRequest __req( this, "brief" );
  __req.add_in_arg( &_sa_pid );
  __req.add_in_arg( &_sa_pm );
  __req.add_in_arg( &_sa_ptime );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
chef::koordinator_stub_clp::brief( CORBA::Long _par_pid, CORBA::Long _par_pm, CORBA::Long _par_ptime )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_chef::koordinator * _myserv = POA_chef::koordinator::_narrow (_serv);
    if (_myserv) {
      _myserv->brief(_par_pid, _par_pm, _par_ptime);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  chef::koordinator_stub::brief(_par_pid, _par_pm, _par_ptime);
}

#endif // MICO_CONF_NO_POA

void chef::koordinator_stub::terminated( CORBA::Long _par_pid, CORBA::Long _par_ggt, CORBA::Long _par_ptime )
{
  CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
  CORBA::StaticAny _sa_ggt( CORBA::_stc_long, &_par_ggt );
  CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );
  CORBA::StaticRequest __req( this, "terminated" );
  __req.add_in_arg( &_sa_pid );
  __req.add_in_arg( &_sa_ggt );
  __req.add_in_arg( &_sa_ptime );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
chef::koordinator_stub_clp::terminated( CORBA::Long _par_pid, CORBA::Long _par_ggt, CORBA::Long _par_ptime )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_chef::koordinator * _myserv = POA_chef::koordinator::_narrow (_serv);
    if (_myserv) {
      _myserv->terminated(_par_pid, _par_ggt, _par_ptime);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  chef::koordinator_stub::terminated(_par_pid, _par_ggt, _par_ptime);
}

#endif // MICO_CONF_NO_POA

void chef::koordinator_stub::closed( CORBA::Long _par_pid, CORBA::Long _par_pm, CORBA::Long _par_ptime )
{
  CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
  CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );
  CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );
  CORBA::StaticRequest __req( this, "closed" );
  __req.add_in_arg( &_sa_pid );
  __req.add_in_arg( &_sa_pm );
  __req.add_in_arg( &_sa_ptime );

  __req.oneway();

  mico_sii_throw( &__req, 
    0);
}


#ifndef MICO_CONF_NO_POA

void
chef::koordinator_stub_clp::closed( CORBA::Long _par_pid, CORBA::Long _par_pm, CORBA::Long _par_ptime )
{
  PortableServer::Servant _serv = _preinvoke ();
  if (_serv) {
    POA_chef::koordinator * _myserv = POA_chef::koordinator::_narrow (_serv);
    if (_myserv) {
      _myserv->closed(_par_pid, _par_pm, _par_ptime);
      _myserv->_remove_ref();
      _postinvoke ();
      return;
    }
    _postinvoke ();
  }

  chef::koordinator_stub::closed(_par_pid, _par_pm, _par_ptime);
}

#endif // MICO_CONF_NO_POA

struct __tc_init_CHEF {
  __tc_init_CHEF()
  {
    _marshaller_chef_koordinator = new _Marshaller_chef_koordinator;
  }

  ~__tc_init_CHEF()
  {
    delete static_cast<_Marshaller_chef_koordinator*>(_marshaller_chef_koordinator);
  }
};

static __tc_init_CHEF __init_CHEF;

//--------------------------------------------------------
//  Implementation of skeletons
//--------------------------------------------------------

// PortableServer Skeleton Class for interface chef::koordinator
POA_chef::koordinator::~koordinator()
{
}

::chef::koordinator_ptr
POA_chef::koordinator::_this ()
{
  CORBA::Object_var obj = PortableServer::ServantBase::_this();
  return ::chef::koordinator::_narrow (obj);
}

CORBA::Boolean
POA_chef::koordinator::_is_a (const char * repoid)
{
  if (strcmp (repoid, "IDL:chef/koordinator:1.0") == 0) {
    return TRUE;
  }
  return FALSE;
}

CORBA::InterfaceDef_ptr
POA_chef::koordinator::_get_interface ()
{
  CORBA::InterfaceDef_ptr ifd = PortableServer::ServantBase::_get_interface ("IDL:chef/koordinator:1.0");

  if (CORBA::is_nil (ifd)) {
    mico_throw (CORBA::OBJ_ADAPTER (0, CORBA::COMPLETED_NO));
  }

  return ifd;
}

CORBA::RepositoryId
POA_chef::koordinator::_primary_interface (const PortableServer::ObjectId &, PortableServer::POA_ptr)
{
  return CORBA::string_dup ("IDL:chef/koordinator:1.0");
}

CORBA::Object_ptr
POA_chef::koordinator::_make_stub (PortableServer::POA_ptr poa, CORBA::Object_ptr obj)
{
  return new ::chef::koordinator_stub_clp (poa, obj);
}

bool
POA_chef::koordinator::dispatch (CORBA::StaticServerRequest_ptr __req)
{
  #ifdef HAVE_EXCEPTIONS
  try {
  #endif
    switch (mico_string_hash (__req->op_name(), 7)) {
    case 0:
      if( strcmp( __req->op_name(), "getsteeringval" ) == 0 ) {
        CORBA::Long _par_pnum;
        CORBA::StaticAny _sa_pnum( CORBA::_stc_long, &_par_pnum );
        CORBA::Long _par_wtime;
        CORBA::StaticAny _sa_wtime( CORBA::_stc_long, &_par_wtime );
        CORBA::Long _par_term;
        CORBA::StaticAny _sa_term( CORBA::_stc_long, &_par_term );

        CORBA::Long _res;
        CORBA::StaticAny __res( CORBA::_stc_long, &_res );
        __req->add_out_arg( &_sa_pnum );
        __req->add_out_arg( &_sa_wtime );
        __req->add_out_arg( &_sa_term );
        __req->set_result( &__res );

        if( !__req->read_args() )
          return true;

        _res = getsteeringval( _par_pnum, _par_wtime, _par_term );
        __req->write_results();
        return true;
      }
      break;
    case 1:
      if( strcmp( __req->op_name(), "closed" ) == 0 ) {
        CORBA::Long _par_pid;
        CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
        CORBA::Long _par_pm;
        CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );
        CORBA::Long _par_ptime;
        CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );

        __req->add_in_arg( &_sa_pid );
        __req->add_in_arg( &_sa_pm );
        __req->add_in_arg( &_sa_ptime );

        if( !__req->read_args() )
          return true;

        closed( _par_pid, _par_pm, _par_ptime );
        __req->write_results();
        return true;
      }
      break;
    case 2:
      if( strcmp( __req->op_name(), "terminated" ) == 0 ) {
        CORBA::Long _par_pid;
        CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
        CORBA::Long _par_ggt;
        CORBA::StaticAny _sa_ggt( CORBA::_stc_long, &_par_ggt );
        CORBA::Long _par_ptime;
        CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );

        __req->add_in_arg( &_sa_pid );
        __req->add_in_arg( &_sa_ggt );
        __req->add_in_arg( &_sa_ptime );

        if( !__req->read_args() )
          return true;

        terminated( _par_pid, _par_ggt, _par_ptime );
        __req->write_results();
        return true;
      }
      break;
    case 4:
      if( strcmp( __req->op_name(), "hello" ) == 0 ) {
        CORBA::Long _par_pid;
        CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );

        CORBA::Long _res;
        CORBA::StaticAny __res( CORBA::_stc_long, &_res );
        __req->add_in_arg( &_sa_pid );
        __req->set_result( &__res );

        if( !__req->read_args() )
          return true;

        _res = hello( _par_pid );
        __req->write_results();
        return true;
      }
      break;
    case 5:
      if( strcmp( __req->op_name(), "brief" ) == 0 ) {
        CORBA::Long _par_pid;
        CORBA::StaticAny _sa_pid( CORBA::_stc_long, &_par_pid );
        CORBA::Long _par_pm;
        CORBA::StaticAny _sa_pm( CORBA::_stc_long, &_par_pm );
        CORBA::Long _par_ptime;
        CORBA::StaticAny _sa_ptime( CORBA::_stc_long, &_par_ptime );

        __req->add_in_arg( &_sa_pid );
        __req->add_in_arg( &_sa_pm );
        __req->add_in_arg( &_sa_ptime );

        if( !__req->read_args() )
          return true;

        brief( _par_pid, _par_pm, _par_ptime );
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
POA_chef::koordinator::invoke (CORBA::StaticServerRequest_ptr __req)
{
  if (dispatch (__req)) {
      return;
  }

  CORBA::Exception * ex = 
    new CORBA::BAD_OPERATION (0, CORBA::COMPLETED_NO);
  __req->set_exception (ex);
  __req->write_results();
}

