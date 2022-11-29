# flutter_ugc_upload

flutter_ugc_upload

## Getting Started

### 集成

如果您在 `Podfile` 中使用 `use_frameworks!`，请按以下示例进行修改你的 `Podfile` 文件。

```ruby
# 省略上方非关键代码
target 'Runner' do
  use_frameworks!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  # If you use `use_frameworks!` in your Podfile,
  # uncomment the below $static_framework array and also
  # the pre_install section. 
  $static_framework = ['flutter_txugcupload']
  
  pre_install do |installer|
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
    installer.pod_targets.each do |pod|
        if $static_framework.include?(pod.name)
          def pod.build_type;
            Pod::BuildType.static_library
          end
        end
      end
  end
end
# 省略下方非关键代码
```

