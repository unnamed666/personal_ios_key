#coding:utf-8

import sys
import os
import traceback
import subprocess
import shutil
import datetime
import codecs
import glob,re

import time
import urllib2
import time
import json
import mimetypes
#蒲公英应用上传地址
url = 'https://qiniu-storage.pgyer.com/apiv1/app/upload'
#蒲公英提供的 用户Key
uKey = '151ddfce6c0202ac9db7514d33a50688'
#蒲公英提供的 API Key
_api_key = '292e6f251062573501a4f6f85c3e0f55'

#安装应用时需要输入的密码，这个可不填
installPassword = '123456'
#处理 蒲公英 上传结果
def handle_resule(result):
    json_result = json.loads(result)
    if json_result['code'] is 0:
        print '*******文件上传成功****'
        print  json_result

def _encode_multipart(params_dict):
    boundary = '----------%s' % hex(int(time.time() * 1000))
    data = []
    for k, v in params_dict.items():
        data.append('--%s' % boundary)
        if hasattr(v, 'read'):
            filename = getattr(v, 'name', '')
            content = v.read()
            decoded_content = content.decode('ISO-8859-1')
            data.append('Content-Disposition: form-data; name="%s"; filename="kangda.ipa"' % k)
            data.append('Content-Type: application/octet-stream\r\n')
            data.append(decoded_content)
        else:
            data.append('Content-Disposition: form-data; name="%s"\r\n' % k)
            data.append(v if isinstance(v, str) else v.decode('utf-8'))
    data.append('--%s--\r\n' % boundary)
    return '\r\n'.join(data), boundary


def generate_installation(template_file, out_file, parameters):
    if not os.path.exists(template_file):
        return False
    if len(parameters.keys()) == 0:
        return False

    lines = []
    with codecs.open(template_file, u"r", u"utf-8") as inf:
        for line in inf:
            for key in parameters.keys():
                line = line.replace(u"{%s}" % key, parameters[key])
            lines.append(line)

    if len(lines) == 0:
        return False

    with codecs.open(out_file, u"w", u"utf-8") as outf:
        outf.writelines(lines)

    return True
def copyfile_to_ftp(local_path, ftp_path):
    import ftplib
    import urlparse
    u = urlparse.urlparse(ftp_path)
    s = ftplib.FTP()
    if u.port:
        s.connect(u.hostname, u.port)
    else:
        s.connect(u.hostname, 21)

    if u.username:
        if u.password:
            s.login(u.username, u.password)
        else:
            s.login(u.username)
    else:
        s.login()
    if len(u.path) > 0:
        remote_path = u.path
    else:
        remote_path = '/'
    s.cwd(remote_path)

    file_name = local_path.split('/')[-1]
    s.storbinary('STOR ' + file_name, open(local_path, 'rb'))

def copydir_to_ftp(local_path,  ftp_path, ftp_dirname):
    import ftplib
    import urlparse
    u = urlparse.urlparse(ftp_path)
    s = ftplib.FTP()
    if u.port:
        s.connect(u.hostname, u.port)
    else:
        s.connect(u.hostname, 21)
        
    if u.username:
        if u.password:
            s.login(u.username, u.password)
        else:
            s.login(u.username)
    else:
        s.login()
    if len(u.path) > 0:
        remote_path = u.path
    else:
        remote_path = '/'
    s.cwd(remote_path)

    if ftp_dirname != '':
        print "<ftp>mkdir: " + remote_path + '/' + ftp_dirname
        s.mkd(ftp_dirname)
        s.cwd(remote_path + '/' + ftp_dirname)

    for root, dirs, files in os.walk(local_path):
        remot_root = remote_path + '/' + ftp_dirname + root[len(local_path):].replace('\\','/')
        print "<ftp>cwd: " + remot_root
        s.cwd(remot_root)
        print s.pwd()
        for name in files:
            fpath = root + '/' + name
            print "<ftp>upload: " + remot_root + '/' + name
            s.storbinary('STOR '+ name, open(fpath, 'rb'))
        for name in dirs:
            print "<ftp>mkdir: " + remot_root + '/' + name
            s.mkd(name)

def generate_adhoc(t):
    if (u"adhoc_install" in t) and (u"adhoc_url" in t):
        adhoc_path = os.path.join(t[u'project_path'], u'const.txt')
        if not os.path.exists(adhoc_path):
            return False

        params = {}
        for line in open(adhoc_path, 'r'):
            line = line.strip()
            if len(line) == 0:
                continue
            offset = line.find('=')
            value = line[offset + 1:]
            key = line[:offset]
            params[key] = value
            print "%s = \"%s\"" %(key, value)

        # 处理adhoc文件名格式
        adhoc_url = t[u"adhoc_url"]
        for k in t.keys():
            adhoc_url = adhoc_url.replace(u"$(%s)" % k, t[k])

        print "adhoc_url:", adhoc_url

        # 在当前目录生成var.txt
        import codecs
        adhoc_var = os.path.join(t[u"project_path"], u"var.txt")
        with codecs.open(adhoc_var, u"w", u"utf-8") as f:
            lines = [
                u"url=%s\n" % adhoc_url,
                u"bundle_version=%s\n" % t[u"build_version"]
            ]
            f.writelines(lines)

        params[u'url'] = adhoc_url
        params[u'bundle_version'] = t[u'build_version']

        if generate_installation(u"template.plist", u"install.plist", params):
            adhoc_install = t[u'adhoc_install']
            if adhoc_install.startswith('ftp://'):
                copyfile_to_ftp(os.path.join(t[u'project_path'], u'install.plist'), adhoc_install)
                copyfile_to_ftp(os.path.join(t[u'project_path'], u'var.txt'), adhoc_install)
            else:
                file_path = os.path.join(adhoc_install, u"install.plist")
                if os.path.exists(file_path):
                    shutil.rmtree(file_path)
                shutil.copyfile(adhoc_var, file_path)

                file_path = os.path.join(adhoc_install, u"var.txt")
                if os.path.exists(file_path):
                    shutil.rmtree(file_path)
                shutil.copyfile(adhoc_var, os.path.join(adhoc_install, u"install.plist"))

def get_provision_uuid(filepath):
    import re
    data = open(filepath,'rb').read()
    rr = re.compile(r'<key>UUID</key>\n\t*<string>([A-Za-z0-9\-]+)</string>',re.M).search(data)
    #rr = re.compile(r'<key>Name</key>\n\t*<string>([\w]+)</string>',re.M).search(data)
    if not rr:
        print "Invalid provision file: %s"%filepath
        sys.exit(1)
    return rr.group(1)

def get_provision_name(filepath):
    import re
    data = open(filepath,'rb').read()
    #rr = re.compile(r'<key>UUID</key>\n\t*<string>([A-Za-z0-9\-]+)</string>',re.M).search(data)
    rr = re.compile(r'<key>Name</key>\n\t*<string>([^<]+)</string>',re.M).search(data)
    if not rr:
        print "Invalid provision file name: %s"%filepath
        sys.exit(1)
    return rr.group(1)

def zip_dir_content(dir_path, outpath):
    retcode = 0
    old_cwd = os.getcwd()
    os.chdir( dir_path )
    print 'old_cwd:'+old_cwd
    print 'cur_dir:'+dir_path
    print 'dir_path--->'+dir_path;
    lstfiles = glob.glob(dir_path+'/*.*');
    print lstfiles;

    cmdline = 'zip -v -r -y "%s" *'%outpath
    print cmdline
    retcode = os.system(cmdline)
    os.chdir( old_cwd )
    return (retcode == 0)

def update_bundle_info(t):
    print '...update_bundle_info...'
    # print t
    project_path = t[u'project_path']
    bundle_version = t[u'build_version']
    print project_path;
    print bundle_version;
    if 'info_plist3' in t:
        print 'info_plist in t'
        info_plist_path = os.path.join(project_path, t[u'info_plist3'])
        print 'info.plist = %s' %(info_plist_path)

        import plistlib
        info = plistlib.readPlist(info_plist_path)

        info[u'CFBundleVersion'] = bundle_version
        print 'CFBundleVersion = %s' %(info[u'CFBundleVersion'])

        version_part = bundle_version.split('.')
        info[u'CFBundleShortVersionString'] = version_part[0] + '.' + version_part[1] + '.' + version_part[2]

        print 'CFBundleShortVersionString = %s' % (info[u'CFBundleShortVersionString'])

        if 'bundle_id' in t:
            info[u'CFBundleIdentifier'] = t[u'bundle_id']
            print 'CFBundleIdentifier = %s' % (t[u'bundle_id'])

        plistlib.writePlist(info, info_plist_path)

    if 'info_plist2' in t:
        print 'info_plist in t'
        info_plist_path = os.path.join(project_path, t[u'info_plist2'])
        print 'info.plist = %s' %(info_plist_path)

        import plistlib
        info = plistlib.readPlist(info_plist_path)

        info[u'CFBundleVersion'] = bundle_version
        print 'CFBundleVersion = %s' %(info[u'CFBundleVersion'])

        version_part = bundle_version.split('.')
        info[u'CFBundleShortVersionString'] = version_part[0] + '.' + version_part[1] + '.' + version_part[2]

        print 'CFBundleShortVersionString = %s' % (info[u'CFBundleShortVersionString'])

        if 'bundle_id' in t:
            info[u'CFBundleIdentifier'] = t[u'bundle_id']
            print 'CFBundleIdentifier = %s' % (t[u'bundle_id'])

        plistlib.writePlist(info, info_plist_path)

    if 'info_plist' in t:
        print 'info_plist in t'
        info_plist_path = os.path.join(project_path, t[u'info_plist'])
        print 'info.plist = %s' %(info_plist_path)

        import plistlib
        info = plistlib.readPlist(info_plist_path)

        info[u'CFBundleVersion'] = bundle_version
        print 'CFBundleVersion = %s' %(info[u'CFBundleVersion'])

        version_part = bundle_version.split('.')
        info[u'CFBundleShortVersionString'] = version_part[0] + '.' + version_part[1] + '.' + version_part[2]

        print 'CFBundleShortVersionString = %s' % (info[u'CFBundleShortVersionString'])

        if 'bundle_id' in t:
            info[u'CFBundleIdentifier'] = t[u'bundle_id']
            print 'CFBundleIdentifier = %s' % (t[u'bundle_id'])

        plistlib.writePlist(info, info_plist_path)
        return True

    for f in os.listdir(project_path):
        if f.endswith(u'-Info.plist'):
            info_plist_path = os.path.join(project_path, f)
            print 'info.plist = %s' %(info_plist_path)

            t[u'info_plist'] = info_plist_path

            import plistlib
            info = plistlib.readPlist(info_plist_path)

            info[u'CFBundleVersion'] = bundle_version
            print 'CFBundleVersion = %s' %(info[u'CFBundleVersion'])
        
            version_part = bundle_version.split('.')
            info[u'CFBundleShortVersionString'] = version_part[0] + '.' + version_part[1] + '.' + version_part[2]
        
            print 'CFBundleShortVersionString = %s' % (info[u'CFBundleShortVersionString'])

            if 'bundle_id' in t:
                info[u'CFBundleIdentifier'] = t[u'bundle_id']
                print 'CFBundleIdentifier = %s' % (t[u'bundle_id'])

            plistlib.writePlist(info, info_plist_path)
            return True
            
    return False

def archive_xcode_proj(t, proj, config, target, xcconfig, scheme, archivePath):
    cmd_line = u'xcodebuild clean build '
    if proj:
        cmd_line = cmd_line + u'archive -workspace "%s" '%proj
    if config:
        cmd_line = cmd_line + u'-configuration "%s" '%config
    if xcconfig:
        cmd_line = cmd_line + u'-xcconfig "%s" '%xcconfig
    if scheme:
        cmd_line = cmd_line + u'-scheme "%s" '%scheme
    if archivePath:
        cmd_line = cmd_line + u'-archivePath "%s" '%archivePath
    cmd_line = cmd_line + u'-sdk iphoneos '

    print "archive_xcode_proj command " +  cmd_line
    return 0 == os.system(cmd_line)
    # return 1
def export_xcarchive(archivePath, exportPath, exportProvisioningProfile):
    cmd_line = u'xcodebuild -exportArchive '
    if archivePath:
        cmd_line = cmd_line + u'-archivePath "%s" '%archivePath
    if exportPath:
        cmd_line = cmd_line + u'-exportPath "%s" '%exportPath
    if exportProvisioningProfile:
        cmd_line = cmd_line + u'-exportOptionsPlist "%s" '%exportProvisioningProfile
    # cmd_line = cmd_line + u'-exportFormat ipa '
    print "export_xcarchive command " +  cmd_line
    return 0 == os.system(cmd_line)

def build_task(t):
    project_name = None
    config = None
    target = None

    project_name  = t[u'project_name']
    config  = t[u'build_config']
    if u'build_target' in t:
        target  = t[u'build_target']

    build_result = update_bundle_info(t)
    if not build_result:
        print "update_bundle_info failed"
        sys.exit(1)

    print "Process provisionging profiles..."

    buildconfig_root = os.path.join(t[u'project_path'], 'buildconfig')

    print "Process adhoc provisioning profiles..."
    user_provision_root = os.path.expanduser('~/Library/MobileDevice/Provisioning Profiles')


    if os.path.exists(buildconfig_root) and os.path.isdir(buildconfig_root):
        #处理buildconfig_cheetah对应的provision文件  iOS Development
        # Developmentprovision_filename = t[u'build_config'] + '.mobileprovision'
        Developmentprovision_filename = 'singDevelopment.mobileprovision'
        Developmentprovision_filepath = os.path.join(buildconfig_root, Developmentprovision_filename)
        if os.path.exists(Developmentprovision_filepath):
            assert(not os.path.isdir(Developmentprovision_filepath))
            Developmentprovision_uuid = get_provision_uuid(Developmentprovision_filepath)
            Developmentprovision_uuid_name = Developmentprovision_uuid + '.mobileprovision'
            shutil.copyfile(Developmentprovision_filepath, os.path.join(user_provision_root, Developmentprovision_uuid_name))


    adhoc_provision_filename = 'adhocDistribution.mobileprovision'
    adhoc_provision_filepath = os.path.join(buildconfig_root, adhoc_provision_filename)

    if os.path.exists(adhoc_provision_filepath):
        assert(not os.path.isdir(adhoc_provision_filepath))
        adhoc_provision_uuid = get_provision_uuid(adhoc_provision_filepath)
        adhoc_provision_uuid_name = adhoc_provision_uuid + '.mobileprovision'
        adhoc_provision_name = get_provision_name(adhoc_provision_filepath)

        print '%s provision: %s -> %s'%(t[u'build_config'], adhoc_provision_filepath, adhoc_provision_uuid_name)
        shutil.copyfile(adhoc_provision_filepath, os.path.join(user_provision_root, adhoc_provision_uuid_name))
        t[u'build_config_adhoc_provision_path'] = os.path.join(user_provision_root, adhoc_provision_uuid_name)

    assert(not os.path.isdir(adhoc_provision_filepath))
    t[u'adhoc_provision_fullpath'] = adhoc_provision_filepath

    print 'adhoc provision: %s'%(adhoc_provision_filepath)

    # if True:
    #     return


    # 编译
    print "Build the project..."
    old_cwd = os.getcwd()
    os.chdir( t[u'project_path'] )

    build_dir = os.path.join(t[u'project_path'], u'build')
    t[u'build_dir'] = build_dir

    archiveFilesPath = os.path.join(build_dir, u'archivefiles.xcarchive')


    build_result = archive_xcode_proj(t, project_name + '.xcworkspace', config, target, None,project_name,archiveFilesPath)
    os.chdir( old_cwd )
    if not build_result:
        sys.exit(1)

    archive_name = t[u'archive_name_format']
    for k in t.keys():
        archive_name = archive_name.replace('$(%s)'%k,t[k])
    t[u"archive_name_format"] = archive_name

    #     #创建存档包
    t[u'tmp_path'] = os.tempnam()
    tmp_archive_path = os.path.join( t[u'tmp_path'], archive_name )
    os.makedirs(tmp_archive_path)
    tmp_archive_zip_path = os.path.join(tmp_archive_path, 'archive.zip')
    if not zip_dir_content(archiveFilesPath, tmp_archive_zip_path):
        print 'zip build_result_path failed'
        sys.exit(1)


    shutil.copyfile(tmp_archive_zip_path,os.path.join(build_dir, 'archive.zip'))
    
    app_path = None
    tmp_build_result_path = os.path.join(archiveFilesPath, u'Products/Applications')

    for f in os.listdir(tmp_build_result_path):

        if os.path.splitext(f)[1] == '.app':

            app_path = os.path.join(tmp_build_result_path, f)

            break

    if not app_path:

        print 'app not found'

        sys.exit(1)
    print "app_path = " + app_path
    #创建adhoc_ipa
    if u'adhoc_ipa_name_format' in t:
        adhoc_ipa_name_format = t[u'adhoc_ipa_name_format']
        for k in t.keys():
            adhoc_ipa_name_format = adhoc_ipa_name_format.replace('$(%s)'%k,t[k])
        t[u'adhoc_ipa_name_format'] = adhoc_ipa_name_format
        build_result = export_xcarchive(archiveFilesPath, build_dir, os.path.join(buildconfig_root, "adhoc.plist"))
    print t[u'adhoc_ipa_name_format']
    if not build_result:
        sys.exit(1)


    os.path.join(build_dir, project_name) +".ipa"
    shutil.move(os.path.join(build_dir, project_name) +".ipa",os.path.join(build_dir, adhoc_ipa_name_format))

    shutil.rmtree(archiveFilesPath)
    # if True:
    #     return
    archive_root = t[u'archive_root']
    if archive_root.startswith('ftp://'):
        copydir_to_ftp( build_dir, archive_root, archive_name )
    else:
        shutil.copytree(build_dir, os.path.join(archive_root, archive_name), True)

    # generate_adhoc(t)

    shutil.rmtree(t[u'tmp_path'])
    #上传蒲公英
    #请求参数字典
    params = {
        'uKey': uKey,
        '_api_key': _api_key,
        'file': open(os.path.join(build_dir, adhoc_ipa_name_format), 'rb'),
        'publishRange': '2',
        'password': installPassword

    }

    coded_params, boundary = _encode_multipart(params)
    req = urllib2.Request(url, coded_params.encode('ISO-8859-1'))
    req.add_header('Content-Type', 'multipart/form-data; boundary=%s' % boundary)
    try:
        print '*******开始文件上传****'
        resp = urllib2.urlopen(req)
        body = resp.read().decode('utf-8')
        handle_resule(body)

    except urllib2.HTTPError as e:
        print(e.fp.read())


def modify_teamid(t):
    project_name  = t[u'project_name']
    filename = project_name + ".xcodeproj/project.pbxproj"
    build_pattern = r'''DEVELOPMENT_TEAM[\s]*=[\s]*([A-Za-z0-9]*);'''
    rawString = open(filename, "rb").read()
    newString = re.sub(build_pattern, lambda m : '''DEVELOPMENT_TEAM = RKFT92L7M9;''', rawString)

    build_pattern = r'''DevelopmentTeam[\s]*=[\s]*([A-Za-z0-9]*);'''
    newString = re.sub(build_pattern, lambda m : '''DevelopmentTeam = RKFT92L7M9;''', newString)


    fw = open(filename, "wb")
    if fw == None:
        raise ("file can't write")

    fw.write(newString);
    fw.close()

def modify_EnterpriseGroupid(t):
    filename = './KeyboardKit/Config/CMGroupDataManager.m'
    build_pattern = r'''static NSString \* kGroupId(.)*'''
    rawString = open(filename, "rb").read()
    newString = re.sub(build_pattern, lambda m : '''static NSString * kGroupId = @"group.com.cheetah.keyboard";''', rawString)
    fw = open(filename, "wb")
    if fw == None:
        raise ("file can't write")

    fw.write(newString);
    fw.close()

def buildEnterprise_task(t):


    modify_EnterpriseGroupid(t)
    modify_teamid(t)

    project_name = None
    config = None
    target = None
    scheme = t[u'scheme']
    project_name  = t[u'project_name']
    config  = t[u'build_config']
    if u'build_target' in t:
        target  = t[u'build_target']

    build_result = update_bundle_info(t)
    if not build_result:
        print "update_bundle_info failed"
        sys.exit(1)

    print "Process provisionging profiles..."

    buildconfig_root = os.path.join(t[u'project_path'], 'buildconfigEnterprise')

    print "Process adhoc provisioning profiles..."
    user_provision_root = os.path.expanduser('~/Library/MobileDevice/Provisioning Profiles')

    array = ('comcheetahkeyboardExtension.mobileprovision','comcheetahkeyboard.mobileprovision','comcheetahkeyboardiMessageE.mobileprovision')
    if os.path.exists(buildconfig_root) and os.path.isdir(buildconfig_root):
        for prefile in array:
            filepath = os.path.join(buildconfig_root, prefile)
            print filepath
            if os.path.exists(filepath):
                assert(not os.path.isdir(filepath))
                uuid = get_provision_uuid(filepath)
                uuid_name = uuid + '.mobileprovision'
                shutil.copyfile(filepath, os.path.join(user_provision_root, uuid_name))

    # 编译
    print "Build the project..."
    old_cwd = os.getcwd()
    os.chdir( t[u'project_path'] )

    build_dir = os.path.join(t[u'project_path'], u'build')
    t[u'build_dir'] = build_dir

    archiveFilesPath = os.path.join(build_dir, u'archivefiles.xcarchive')


    build_result = archive_xcode_proj(t, project_name + '.xcworkspace', config, target, None,scheme,archiveFilesPath)
    os.chdir( old_cwd )
    if not build_result:
        sys.exit(1)


    archive_name = t[u'archive_name_format']
    for k in t.keys():
        archive_name = archive_name.replace('$(%s)'%k,t[k])
    t[u"archive_name_format"] = archive_name

         #创建存档包
    t[u'tmp_path'] = os.tempnam()
    tmp_archive_path = os.path.join( t[u'tmp_path'], archive_name )
    os.makedirs(tmp_archive_path)
    tmp_archive_zip_path = os.path.join(tmp_archive_path, 'archive.zip')
    if not zip_dir_content(os.path.join(archiveFilesPath, 'dSYMs' ), tmp_archive_zip_path):
        print 'zip build_result_path failed'
        sys.exit(1)


    shutil.copyfile(tmp_archive_zip_path,os.path.join(build_dir, 'archive.zip'))
    
    app_path = None
    tmp_build_result_path = os.path.join(archiveFilesPath, u'Products/Applications')

    for f in os.listdir(tmp_build_result_path):

        if os.path.splitext(f)[1] == '.app':

            app_path = os.path.join(tmp_build_result_path, f)

            break

    if not app_path:

        print 'app not found'

        sys.exit(1)
    print "app_path = " + app_path
    #创建appStore_ipa
    if u'enterprise_ipa_name_format' in t:
        enterprise_ipa_name_format = t[u'enterprise_ipa_name_format']
        for k in t.keys():
            enterprise_ipa_name_format = enterprise_ipa_name_format.replace('$(%s)'%k,t[k])
        t[u'enterprise_ipa_name_format'] = enterprise_ipa_name_format
        build_result = export_xcarchive(archiveFilesPath, build_dir, os.path.join(buildconfig_root, "cmEnterprise.plist"))
    print t[u'enterprise_ipa_name_format']
    if not build_result:
        sys.exit(1)
 
    shutil.move(os.path.join(build_dir, scheme) +".ipa",os.path.join(build_dir, enterprise_ipa_name_format))


    shutil.rmtree(archiveFilesPath)



    #上传蒲公英
    #请求参数字典
    params = {
        'uKey': uKey,
        '_api_key': _api_key,
        'file': open(os.path.join(build_dir, enterprise_ipa_name_format), 'rb'),
        'publishRange': '2',
        'password': installPassword

    }

    coded_params, boundary = _encode_multipart(params)
    req = urllib2.Request(url, coded_params.encode('ISO-8859-1'))
    req.add_header('Content-Type', 'multipart/form-data; boundary=%s' % boundary)
    try:
        print '*******蒲公英开始文件上传****'
        resp = urllib2.urlopen(req)
        body = resp.read().decode('utf-8')
        handle_resule(body)

    except urllib2.HTTPError as e:
        print(e.fp.read())

    
    # if True:
    #     return

    archive_root = t[u'archive_root']
    if archive_root.startswith('ftp://'):
        print '*******ftp开始文件上传****'
        copydir_to_ftp( build_dir, archive_root, archive_name )
        print '*******ftp文件上传结束****'
    else:
        shutil.copytree(build_dir, os.path.join(archive_root, archive_name), True)

    # generate_adhoc(t)

    shutil.rmtree(t[u'tmp_path'])
    shutil.rmtree(build_dir)


def main():
    _module_fullname = os.path.abspath( sys.modules[__name__].__file__ )
    _module_dir  = os.path.dirname(_module_fullname)
    buildcfg = os.path.join(_module_dir, u'buildcfg')
    if not os.path.exists(buildcfg):
        print 'error: %s not exists'%buildcfg
        sys.exit(1)

    print "Analyzing input parameters:"
    t = {}
    for l in open(buildcfg, 'r'):
        l = l.strip()
        if len(l) == 0:
            continue
        off = l.find('=')
        v = l[off+1:]
        k = l[:off]
        t[k] = v
        print "%s = \"%s\"" %(k, v)

    print "Checking parameters..."
    assert( u'project_path' in t )
    assert( u'project_name' in t )
    assert( u'build_config' in t )
    #assert( u'app_version' in t )
    #assert( u'build_revision' in t )
    #assert( u'build_number' in t )
    assert( u'archive_root' in t )
    assert( u'archive_name_format' in t )
    #assert( u'dist_ipa_name_format' in t )
    #assert( u'adhoc_ipa_name_format' in t )
    if (u'dist_ipa_name_format' not in t) and( u'adhoc_ipa_name_format' not in t ):
        if u'ipa_name_format' in t:
            t[u'adhoc_ipa_name_format'] = t[u'ipa_name_format']
    assert( u'build_time' in t )
    assert( u'build_version' in t )
    if len(t[u'build_version'].split('.')) != 4:
        print 'error: build_version format error. build_version=%s'%t[u'build_version']
        sys.exit(1)
    
    buildEnterprise_task(t)

    # try:
        # shutil.rmtree(t[u'project_path'] +"/build")
    # build_task(t)
    # finally:
        # if u'build_config_provision_path' in t:
        #     print 'delete %s'%t[u'build_config_provision_path']
        #     os.remove(t[u'build_config_provision_path'])
        # if u'build_config_adhoc_provision_path' in t:
        #     print 'delete %s'%t[u'build_config_adhoc_provision_path']
        #     os.remove(t[u'build_config_adhoc_provision_path'])

if __name__ == u'__main__':
    main()
