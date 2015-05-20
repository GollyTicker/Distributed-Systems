/*
 *  MICO --- an Open Source CORBA implementation
 *  Copyright (c) 1997-2006 by The Mico Team
 *
 *  This file was automatically generated. DO NOT EDIT!
 */

#include <CORBA.h>
#include <mico/throw.h>

#ifndef __GGT_H__
#define __GGT_H__






namespace ggt
{

class unit;
typedef unit *unit_ptr;
typedef unit_ptr unitRef;
typedef ObjVar< unit > unit_var;
typedef ObjOut< unit > unit_out;

}






namespace ggt
{


/*
 * Base class and common definitions for interface unit
 */

class unit : 
  virtual public CORBA::Object
{
  public:
    virtual ~unit();

    #ifdef HAVE_TYPEDEF_OVERLOAD
    typedef unit_ptr _ptr_type;
    typedef unit_var _var_type;
    #endif

    static unit_ptr _narrow( CORBA::Object_ptr obj );
    static unit_ptr _narrow( CORBA::AbstractBase_ptr obj );
    static unit_ptr _duplicate( unit_ptr _obj )
    {
      CORBA::Object::_duplicate (_obj);
      return _obj;
    }

    static unit_ptr _nil()
    {
      return 0;
    }

    virtual void *_narrow_helper( const char *repoid );

    virtual CORBA::Long setneighbors( CORBA::Long pidleft, CORBA::Long pidright ) = 0;
    virtual void setpm( CORBA::Long pm ) = 0;
    virtual void sendy( CORBA::Long y ) = 0;
    virtual void query() = 0;
    virtual void response( CORBA::Long y ) = 0;
    virtual void close() = 0;

  protected:
    unit() {};
  private:
    unit( const unit& );
    void operator=( const unit& );
};

// Stub for interface unit
class unit_stub:
  virtual public unit
{
  public:
    virtual ~unit_stub();
    CORBA::Long setneighbors( CORBA::Long pidleft, CORBA::Long pidright );
    void setpm( CORBA::Long pm );
    void sendy( CORBA::Long y );
    void query();
    void response( CORBA::Long y );
    void close();

  private:
    void operator=( const unit_stub& );
};

#ifndef MICO_CONF_NO_POA

class unit_stub_clp :
  virtual public unit_stub,
  virtual public PortableServer::StubBase
{
  public:
    unit_stub_clp (PortableServer::POA_ptr, CORBA::Object_ptr);
    virtual ~unit_stub_clp ();
    CORBA::Long setneighbors( CORBA::Long pidleft, CORBA::Long pidright );
    void setpm( CORBA::Long pm );
    void sendy( CORBA::Long y );
    void query();
    void response( CORBA::Long y );
    void close();

  protected:
    unit_stub_clp ();
  private:
    void operator=( const unit_stub_clp & );
};

#endif // MICO_CONF_NO_POA

}


#ifndef MICO_CONF_NO_POA



namespace POA_ggt
{

class unit : virtual public PortableServer::StaticImplementation
{
  public:
    virtual ~unit ();
    ggt::unit_ptr _this ();
    bool dispatch (CORBA::StaticServerRequest_ptr);
    virtual void invoke (CORBA::StaticServerRequest_ptr);
    virtual CORBA::Boolean _is_a (const char *);
    virtual CORBA::InterfaceDef_ptr _get_interface ();
    virtual CORBA::RepositoryId _primary_interface (const PortableServer::ObjectId &, PortableServer::POA_ptr);

    virtual void * _narrow_helper (const char *);
    static unit * _narrow (PortableServer::Servant);
    virtual CORBA::Object_ptr _make_stub (PortableServer::POA_ptr, CORBA::Object_ptr);

    virtual CORBA::Long setneighbors( CORBA::Long pidleft, CORBA::Long pidright ) = 0;
    virtual void setpm( CORBA::Long pm ) = 0;
    virtual void sendy( CORBA::Long y ) = 0;
    virtual void query() = 0;
    virtual void response( CORBA::Long y ) = 0;
    virtual void close() = 0;

  protected:
    unit () {};

  private:
    unit (const unit &);
    void operator= (const unit &);
};

}


#endif // MICO_CONF_NO_POA

extern CORBA::StaticTypeInfo *_marshaller_ggt_unit;

#endif
