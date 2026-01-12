import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../models/business_profile.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final bool isNewBusiness;
  final bool isMandatory;
  const ProfileScreen({
    super.key, 
    this.isNewBusiness = false,
    this.isMandatory = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _proprietorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _customFieldLabelController = TextEditingController();
  final _customFieldPlaceholderController = TextEditingController();
  final _gstinController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  BusinessProfile? _currentProfile;

  // Image URLs
  String? _logoUrl;
  String? _signatureUrl;
  String? _customLogo1Url;
  String? _customLogo2Url;
  String? _customLogo3Url;
  String? _customLogo4Url;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isNewBusiness) {
      _isLoading = false; 
      // Start with empty form for new business
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.businessName;
          _addressController.text = profile.address;
          _proprietorController.text = profile.proprietor;
          _phoneController.text = profile.phoneNumbers;
          
          _logoUrl = profile.logoUrl;
          _signatureUrl = profile.signatureUrl;
          _customLogo1Url = profile.customLogo1Url;
          _customLogo2Url = profile.customLogo2Url;
          _customLogo3Url = profile.customLogo3Url;
          _customLogo4Url = profile.customLogo4Url;
          _customFieldLabelController.text = profile.customFieldLabel ?? '';
          _customFieldPlaceholderController.text = profile.customFieldPlaceholder ?? '';
          _gstinController.text = profile.gstin ?? '';
        });
      }
    } catch (e) {
      // ... same error handling
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppTheme.showToast(context, l10n.errorLoadingProfile, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty) {
      AppTheme.showToast(context, l10n.businessNameRequired, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        AppTheme.showToast(context, l10n.userSessionExpired, isError: true);
        return;
      }
      
      // If isNewBusiness is true, ensure ID is null to create new
      final String? profileId = widget.isNewBusiness ? null : _currentProfile?.id;

      final newProfile = BusinessProfile(
        id: profileId,
        userId: userId,
        businessName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        proprietor: _proprietorController.text.trim(),
        phoneNumbers: _phoneController.text.trim(),
        logoUrl: _logoUrl,
        signatureUrl: _signatureUrl,
        customLogo1Url: _customLogo1Url,
        customLogo2Url: _customLogo2Url,
        customLogo3Url: _customLogo3Url,
        customLogo4Url: _customLogo4Url,
        customFieldLabel: _customFieldLabelController.text.trim(),
        customFieldPlaceholder: _customFieldPlaceholderController.text.trim(),
        gstin: _gstinController.text.trim(),
      );

      await _profileService.saveProfile(newProfile);
      
      if (mounted) {
        AppTheme.showToast(context, l10n.profileSaved);
        if (widget.isMandatory) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        } else {
          Navigator.pop(context, true); // Return success
        }
      }
    } catch (e) {
      if (mounted) {
        // Show specific error for debugging
        AppTheme.showToast(context, 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUpload(String type, String currentUrl) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last;
      final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (mounted) AppTheme.showToast(context, '${l10n.uploading} $type...');

      final url = await _profileService.uploadImage(fileName, bytes);

      if (url != null && mounted) {
        setState(() {
          switch (type) {
            case 'logo': _logoUrl = url; break;
            case 'signature': _signatureUrl = url; break;
            case 'custom1': _customLogo1Url = url; break;
            case 'custom2': _customLogo2Url = url; break;
            case 'custom3': _customLogo3Url = url; break;
            case 'custom4': _customLogo4Url = url; break;
          }
        });
        AppTheme.showToast(context, '$type ${l10n.uploadedSuccess}');
      }
    } catch (e) {
      if (mounted) AppTheme.showToast(context, l10n.errorUploadingImage, isError: true);
    }
  }

  Widget _buildProfileForm() {
    final l10n = AppLocalizations.of(context)!;
    // Remove Card, use direct Column on Surface
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        
        _buildSectionHeader(l10n.businessInfo),
        const SizedBox(height: 16),
        _buildImagePickerItem(l10n.companyLogo, _logoUrl, 'logo'),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _nameController,
          label: '${l10n.businessName} *',
          hint: l10n.enterBusinessName,
          prefixIcon: Icons.storefront_outlined,
        ),
        CustomTextField(
          controller: _proprietorController,
          label: l10n.proprietorName,
          hint: l10n.enterProprietorName,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _gstinController,
          label: l10n.gstin,
          hint: l10n.enterGstin,
          prefixIcon: Icons.assignment_ind_outlined,
        ),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.customFields),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _customFieldLabelController,
          label: l10n.customFieldLabel,
          hint: l10n.enterCustomFieldLabel,
          prefixIcon: Icons.label_outline,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _customFieldPlaceholderController,
          label: l10n.customFieldPlaceholder,
          hint: l10n.enterCustomFieldPlaceholder,
          prefixIcon: Icons.short_text,
        ),
        
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.businessAssets),
        const SizedBox(height: 16),
        _buildImagePickerItem(l10n.proprietorSignature, _signatureUrl, 'signature'),
        const SizedBox(height: 24),
        Text(
          l10n.companionLogos,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildImagePickerItem('${l10n.companyLogo} 1', _customLogo1Url, 'custom1', compact: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildImagePickerItem('${l10n.companyLogo} 2', _customLogo2Url, 'custom2', compact: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildImagePickerItem('${l10n.companyLogo} 3', _customLogo3Url, 'custom3', compact: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildImagePickerItem('${l10n.companyLogo} 4', _customLogo4Url, 'custom4', compact: true)),
          ],
        ),
        
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.contactDetails),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: l10n.contactNumbers,
          hint: l10n.enterContactNumbers,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _addressController,
          label: l10n.businessAddress,
          hint: l10n.enterBusinessAddress,
          prefixIcon: Icons.location_on_outlined,
        ),
        
        const SizedBox(height: 40),
        _isSaving
            ? const Center(child: CircularProgressIndicator())
            : CustomButton(
                text: l10n.saveBusinessProfile,
                onPressed: _handleSave,
              ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildImagePickerItem(String title, String? url, String type, {bool compact = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _pickAndUpload(type, url ?? ''),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: compact ? 120 : 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: url != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(url, fit: BoxFit.contain),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filledTonal(
                          onPressed: () => setState(() {
                            switch (type) {
                              case 'logo': _logoUrl = null; break;
                              case 'signature': _signatureUrl = null; break;
                              case 'custom1': _customLogo1Url = null; break;
                              case 'custom2': _customLogo2Url = null; break;
                              case 'custom3': _customLogo3Url = null; break;
                              case 'custom4': _customLogo4Url = null; break;
                            }
                          }),
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.primary),
                      if (compact) ...[
                         const SizedBox(height: 4),
                         Text(title, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                      ]
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isMandatory ? l10n.createAccount : l10n.profileSettings),
          automaticallyImplyLeading: !widget.isMandatory,
          titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          centerTitle: false,
        ),
        body: ResponsiveLayout(
          mobile: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildProfileForm(),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
